import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/database/local_db.dart';
import '../core/services/sync_service.dart' show localDatabaseProvider;

// Re-export Drift row types so callers only need to import this file.
export '../core/database/local_db.dart' show PreOrderReview, PreOrderReviewItem;

/// DTO passed from the screen to [PreOrderReviewRepository.upsert].
/// Avoids exposing Drift companion types outside the repository.
class PreOrderReviewItemInput {
  final String? productId;
  final String? matchedProductId;
  final String productName;
  final String? productCode;
  final String supplierName;
  final int piecesPerBox;
  final int requestedPieces;
  final int availablePieces;
  final int confirmedPieces;

  const PreOrderReviewItemInput({
    this.productId,
    this.matchedProductId,
    required this.productName,
    this.productCode,
    required this.supplierName,
    required this.piecesPerBox,
    required this.requestedPieces,
    required this.availablePieces,
    required this.confirmedPieces,
  });
}

class PreOrderReviewRepository {
  final LocalDatabase db;
  const PreOrderReviewRepository({required this.db});

  /// Returns all saved reviews, newest first.
  Future<List<PreOrderReview>> getAll() async {
    return (db.select(db.preOrderReviews)
          ..orderBy([(t) => drift.OrderingTerm.desc(t.reviewedAt)]))
        .get();
  }

  /// Returns the most recent saved review for [sourceFile], or null.
  Future<PreOrderReview?> getBySourceFile(String sourceFile) async {
    final rows = await (db.select(db.preOrderReviews)
          ..where((t) => t.sourceFile.equals(sourceFile))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.reviewedAt)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Returns all items for [reviewId].
  Future<List<PreOrderReviewItem>> getItems(String reviewId) async {
    return (db.select(db.preOrderReviewItems)
          ..where((t) => t.reviewId.equals(reviewId)))
        .get();
  }

  /// Replaces any existing review for [sourceFile], then inserts [items].
  /// Returns the new review id.
  Future<String> upsert({
    required String sourceFile,
    required String originalExportedAt,
    required List<PreOrderReviewItemInput> items,
  }) async {
    final existing = await getBySourceFile(sourceFile);
    if (existing != null) {
      await _deleteItems(existing.id);
      await (db.delete(db.preOrderReviews)
            ..where((t) => t.id.equals(existing.id)))
          .go();
    }

    final reviewId = const Uuid().v4();
    await db.into(db.preOrderReviews).insert(PreOrderReviewsCompanion(
          id: drift.Value(reviewId),
          sourceFile: drift.Value(sourceFile),
          originalExportedAt: drift.Value(originalExportedAt),
          reviewedAt: drift.Value(DateTime.now()),
        ));

    for (final item in items) {
      await db.into(db.preOrderReviewItems).insert(
            PreOrderReviewItemsCompanion(
              id: drift.Value(const Uuid().v4()),
              reviewId: drift.Value(reviewId),
              productId: drift.Value(item.productId),
              matchedProductId: drift.Value(item.matchedProductId),
              productName: drift.Value(item.productName),
              productCode: drift.Value(item.productCode),
              supplierName: drift.Value(item.supplierName),
              piecesPerBox: drift.Value(item.piecesPerBox),
              requestedPieces: drift.Value(item.requestedPieces),
              availablePieces: drift.Value(item.availablePieces),
              confirmedPieces: drift.Value(item.confirmedPieces),
            ),
          );
    }

    return reviewId;
  }

  /// Permanently deletes [reviewId] and all its items.
  Future<void> delete(String reviewId) async {
    await _deleteItems(reviewId);
    await (db.delete(db.preOrderReviews)
          ..where((t) => t.id.equals(reviewId)))
        .go();
  }

  Future<void> _deleteItems(String reviewId) async {
    await (db.delete(db.preOrderReviewItems)
          ..where((t) => t.reviewId.equals(reviewId)))
        .go();
  }
}

final preOrderReviewRepositoryProvider =
    Provider<PreOrderReviewRepository>((ref) {
  return PreOrderReviewRepository(db: ref.watch(localDatabaseProvider));
});
