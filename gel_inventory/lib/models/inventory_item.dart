class InventoryItem {
  final String id;
  final String productId;
  final int quantityPieces;
  final DateTime lastUpdated;

  const InventoryItem({
    required this.id,
    required this.productId,
    required this.quantityPieces,
    required this.lastUpdated,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        quantityPieces: j['quantity_pieces'] as int,
        lastUpdated: DateTime.parse(j['last_updated'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'quantity_pieces': quantityPieces,
        'last_updated': lastUpdated.toIso8601String(),
      };
}
