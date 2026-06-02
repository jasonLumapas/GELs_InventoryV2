class VanStock {
  final String id;
  final String productId;
  final String type; // 'out' | 'in'
  final int quantityPieces;
  final DateTime date;
  final String? notes;

  const VanStock({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantityPieces,
    required this.date,
    this.notes,
  });

  factory VanStock.fromJson(Map<String, dynamic> j) => VanStock(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        type: j['type'] as String,
        quantityPieces: j['quantity_pieces'] as int,
        date: DateTime.parse(j['date'] as String),
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'type': type,
        'quantity_pieces': quantityPieces,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  bool get isOut => type == 'out';
}
