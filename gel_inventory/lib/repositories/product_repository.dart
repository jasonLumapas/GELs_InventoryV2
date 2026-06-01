import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/database/local_db.dart' hide Product, ProductPrice;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/product.dart';
import '../models/product_price.dart';
import 'base_repository.dart';

class ProductRepository extends BaseRepository {
  ProductRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  Future<List<Product>> getAll() async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('products')
          .select()
          .eq('is_deleted', false)
          .order('name');
      final products = (data as List).map((j) => Product.fromJson(j)).toList();
      for (final p in products) {
        await _saveLocalProduct(p);
      }
      return products;
    }
    final rows = await (db.select(db.products)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.name)]))
        .get();
    return rows
        .map((r) => Product(
              id: r.id,
              name: r.name,
              supplierId: r.supplierId,
              piecesPerBox: r.piecesPerBox,
              createdAt: r.createdAt,
            ))
        .toList();
  }

  Future<void> upsertProduct(Product product) async {
    final payload = product.toJson();
    if (isOnline) {
      await Supabase.instance.client.from('products').upsert(payload);
    } else {
      await syncService.enqueue(
        tableName: 'products',
        recordId: product.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await _saveLocalProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    // Soft delete — preserves referential integrity with product_prices,
    // inventory, and invoice_items.
    const payload = {'is_deleted': true};
    if (isOnline) {
      await Supabase.instance.client
          .from('products')
          .update(payload)
          .eq('id', id);
    } else {
      await syncService.enqueue(
        tableName: 'products',
        recordId: id,
        operation: 'update',
        payload: payload,
      );
    }
    await (db.update(db.products)..where((t) => t.id.equals(id)))
        .write(const ProductsCompanion(isDeleted: drift.Value(true)));
  }

  Future<void> addPrice(ProductPrice price) async {
    final payload = price.toJson();
    if (isOnline) {
      await Supabase.instance.client.from('product_prices').insert(payload);
    } else {
      await syncService.enqueue(
        tableName: 'product_prices',
        recordId: price.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await db.into(db.productPrices).insertOnConflictUpdate(
          ProductPricesCompanion(
            id: drift.Value(price.id),
            productId: drift.Value(price.productId),
            withdrawalPrice: drift.Value(price.withdrawalPrice),
            sellingPrice: drift.Value(price.sellingPrice),
            effectiveFrom: drift.Value(price.effectiveFrom),
          ),
        );
  }

  Future<ProductPrice?> getCurrentPrice(String productId) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('product_prices')
          .select()
          .eq('product_id', productId)
          .order('effective_from', ascending: false)
          .limit(1);
      if ((data as List).isEmpty) return null;
      return ProductPrice.fromJson(data.first);
    }
    final rows = await (db.select(db.productPrices)
          ..where((t) => t.productId.equals(productId))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.effectiveFrom)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    return ProductPrice(
      id: r.id,
      productId: r.productId,
      withdrawalPrice: r.withdrawalPrice,
      sellingPrice: r.sellingPrice,
      effectiveFrom: r.effectiveFrom,
    );
  }

  Future<List<ProductPrice>> getPriceHistory(String productId) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('product_prices')
          .select()
          .eq('product_id', productId)
          .order('effective_from', ascending: false);
      return (data as List).map((j) => ProductPrice.fromJson(j)).toList();
    }
    final rows = await (db.select(db.productPrices)
          ..where((t) => t.productId.equals(productId))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.effectiveFrom)]))
        .get();
    return rows
        .map((r) => ProductPrice(
              id: r.id,
              productId: r.productId,
              withdrawalPrice: r.withdrawalPrice,
              sellingPrice: r.sellingPrice,
              effectiveFrom: r.effectiveFrom,
            ))
        .toList();
  }

  Future<void> _saveLocalProduct(Product p) async {
    await db.into(db.products).insertOnConflictUpdate(ProductsCompanion(
          id: drift.Value(p.id),
          name: drift.Value(p.name),
          supplierId: drift.Value(p.supplierId),
          piecesPerBox: drift.Value(p.piecesPerBox),
          createdAt: drift.Value(p.createdAt),
        ));
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
  );
});

final productsListProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getAll();
});
