import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/local_db.dart' hide ProductDiscount;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/product_discount.dart';
import 'base_repository.dart';

class ProductDiscountRepository extends BaseRepository {
  ProductDiscountRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  Future<ProductDiscount?> getForProduct(String productId) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('product_discounts')
          .select()
          .eq('product_id', productId)
          .limit(1);
      if ((data as List).isEmpty) return null;
      return ProductDiscount.fromJson(data.first);
    }
    final rows = await (db.select(db.productDiscounts)
          ..where((t) => t.productId.equals(productId))
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    return ProductDiscount(
      id: r.id,
      productId: r.productId,
      minQuantityPieces: r.minQuantityPieces,
      discountValue: r.discountPercent,
      discountType: r.discountType,
      freeQuantityPieces: r.freeQuantityPieces,
    );
  }

  Future<void> upsert(ProductDiscount discount) async {
    final payload = discount.toJson();
    if (isOnline) {
      await Supabase.instance.client
          .from('product_discounts')
          .upsert(payload);
    } else {
      await syncService.enqueue(
        tableName: 'product_discounts',
        recordId: discount.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await trySaveLocal(() => db
        .into(db.productDiscounts)
        .insertOnConflictUpdate(ProductDiscountsCompanion(
          id: drift.Value(discount.id),
          productId: drift.Value(discount.productId),
          minQuantityPieces: drift.Value(discount.minQuantityPieces),
          discountPercent: drift.Value(discount.discountValue),
          discountType: drift.Value(discount.discountType),
          freeQuantityPieces: drift.Value(discount.freeQuantityPieces),
        )));
  }

  Future<void> deleteForProduct(String productId) async {
    if (isOnline) {
      await Supabase.instance.client
          .from('product_discounts')
          .delete()
          .eq('product_id', productId);
    } else {
      final existing = await getForProduct(productId);
      if (existing != null) {
        await syncService.enqueue(
          tableName: 'product_discounts',
          recordId: existing.id,
          operation: 'delete',
          payload: {'id': existing.id},
        );
      }
    }
    await (db.delete(db.productDiscounts)
          ..where((t) => t.productId.equals(productId)))
        .go();
  }
}

final productDiscountRepositoryProvider =
    Provider<ProductDiscountRepository>((ref) {
  return ProductDiscountRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
  );
});

String newId() => const Uuid().v4();
