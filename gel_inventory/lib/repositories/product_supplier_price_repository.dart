import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/database/local_db.dart' hide ProductSupplierPrice;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/product_supplier_price.dart';
import 'base_repository.dart';

class ProductSupplierPriceRepository extends BaseRepository {
  ProductSupplierPriceRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  Future<ProductSupplierPrice?> getForProduct(String productId) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('product_supplier_prices')
          .select()
          .eq('product_id', productId)
          .limit(1);
      if ((data as List).isEmpty) return null;
      return ProductSupplierPrice.fromJson(data.first);
    }
    final rows = await (db.select(db.productSupplierPrices)
          ..where((t) => t.productId.equals(productId))
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    return ProductSupplierPrice(
      id: r.id,
      productId: r.productId,
      priceBox: r.priceBox,
      discountPercents:
          ProductSupplierPrice.decodeDiscountPercents(r.discountPercents),
      vatEnabled: r.vatEnabled,
    );
  }

  Future<void> upsert(ProductSupplierPrice price) async {
    final payload = price.toJson();
    if (isOnline) {
      await Supabase.instance.client
          .from('product_supplier_prices')
          .upsert(payload);
    } else {
      await syncService.enqueue(
        tableName: 'product_supplier_prices',
        recordId: price.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await trySaveLocal(() => db
        .into(db.productSupplierPrices)
        .insertOnConflictUpdate(ProductSupplierPricesCompanion(
          id: drift.Value(price.id),
          productId: drift.Value(price.productId),
          priceBox: drift.Value(price.priceBox),
          discountPercents: drift.Value(
              ProductSupplierPrice.encodeDiscountPercents(
                  price.discountPercents)),
          vatEnabled: drift.Value(price.vatEnabled),
        )));
  }

  Future<void> deleteForProduct(String productId) async {
    if (isOnline) {
      await Supabase.instance.client
          .from('product_supplier_prices')
          .delete()
          .eq('product_id', productId);
    } else {
      final existing = await getForProduct(productId);
      if (existing != null) {
        await syncService.enqueue(
          tableName: 'product_supplier_prices',
          recordId: existing.id,
          operation: 'delete',
          payload: {'id': existing.id},
        );
      }
    }
    await (db.delete(db.productSupplierPrices)
          ..where((t) => t.productId.equals(productId)))
        .go();
  }
}

final productSupplierPriceRepositoryProvider =
    Provider<ProductSupplierPriceRepository>((ref) {
  return ProductSupplierPriceRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
  );
});
