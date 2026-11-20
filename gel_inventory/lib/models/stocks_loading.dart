class StocksLoadingRecord {
  final String id;
  final DateTime loadingDate;
  final DateTime importedAt;
  final List<StocksLoadingEntry> items;

  const StocksLoadingRecord({
    required this.id,
    required this.loadingDate,
    required this.importedAt,
    required this.items,
  });
}

class StocksLoadingEntry {
  final String id;
  final String stocksLoadingId;
  final String? productCode;
  final String productName;
  final String supplierName;
  final int quantityPieces;
  final int piecesPerBox;

  const StocksLoadingEntry({
    required this.id,
    required this.stocksLoadingId,
    this.productCode,
    required this.productName,
    required this.supplierName,
    required this.quantityPieces,
    required this.piecesPerBox,
  });

  int get boxes => piecesPerBox > 0 ? quantityPieces ~/ piecesPerBox : 0;
  int get remainingPieces => piecesPerBox > 0 ? quantityPieces % piecesPerBox : quantityPieces;
}

/// Shape of the JSON file exported from the off-site loading PC.
class StocksLoadingExport {
  final String exportedAt;
  final String loadingDate;
  final List<StocksLoadingExportItem> items;

  const StocksLoadingExport({
    required this.exportedAt,
    required this.loadingDate,
    required this.items,
  });

  factory StocksLoadingExport.fromJson(Map<String, dynamic> json) =>
      StocksLoadingExport(
        exportedAt: json['exportedAt'] as String,
        loadingDate: json['loadingDate'] as String,
        items: (json['items'] as List)
            .map((e) => StocksLoadingExportItem.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );
}

class StocksLoadingExportItem {
  final String productId;
  final String? productCode;
  final String productName;
  final String supplierName;
  final int quantityPieces;
  final int piecesPerBox;

  const StocksLoadingExportItem({
    required this.productId,
    this.productCode,
    required this.productName,
    required this.supplierName,
    required this.quantityPieces,
    required this.piecesPerBox,
  });

  factory StocksLoadingExportItem.fromJson(Map<String, dynamic> json) =>
      StocksLoadingExportItem(
        productId: json['productId'] as String,
        productCode: json['productCode'] as String?,
        productName: json['productName'] as String,
        supplierName: json['supplierName'] as String,
        quantityPieces: json['quantityPieces'] as int,
        piecesPerBox: (json['piecesPerBox'] as int?) ?? 1,
      );
}
