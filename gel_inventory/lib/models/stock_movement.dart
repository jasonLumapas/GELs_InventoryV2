class StockMovement {
  final String id;
  final String productId;
  final String movementType; // 'in' | 'out'
  final int quantityPieces;
  final DateTime? referenceDate;
  final String? invoiceNumber;
  final String? comments;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.movementType,
    required this.quantityPieces,
    this.referenceDate,
    this.invoiceNumber,
    this.comments,
    required this.createdAt,
  });

  bool get isIn => movementType == 'in';

  factory StockMovement.fromJson(Map<String, dynamic> j) => StockMovement(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        movementType: j['movement_type'] as String,
        quantityPieces: j['quantity_pieces'] as int,
        referenceDate: j['reference_date'] == null
            ? null
            : DateTime.parse(j['reference_date'] as String),
        invoiceNumber: j['invoice_number'] as String?,
        comments: j['comments'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'movement_type': movementType,
        'quantity_pieces': quantityPieces,
        'reference_date': referenceDate?.toIso8601String(),
        'invoice_number': invoiceNumber,
        'comments': comments,
        'created_at': createdAt.toIso8601String(),
      };
}
