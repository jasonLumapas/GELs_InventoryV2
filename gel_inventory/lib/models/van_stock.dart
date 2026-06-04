class VanStock {
  final String id;
  final String productId;
  final String type; // 'out' | 'in'
  final int quantityPieces;
  final DateTime date;
  final String? notes;
  final String? areaId;

  const VanStock({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantityPieces,
    required this.date,
    this.notes,
    this.areaId,
  });

  factory VanStock.fromJson(Map<String, dynamic> j) => VanStock(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        type: j['type'] as String,
        quantityPieces: j['quantity_pieces'] as int,
        date: DateTime.parse(j['date'] as String),
        notes: j['notes'] as String?,
        areaId: j['area_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'type': type,
        'quantity_pieces': quantityPieces,
        'date': date.toIso8601String(),
        'notes': notes,
        'area_id': areaId,
      };

  bool get isOut => type == 'out';
}
