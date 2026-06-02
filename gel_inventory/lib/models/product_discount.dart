class ProductDiscount {
  final String id;
  final String productId;
  final int minQuantityPieces;
  final double discountValue; // percent (0-100) or fixed currency amount
  final String discountType; // 'percent' | 'amount'

  const ProductDiscount({
    required this.id,
    required this.productId,
    required this.minQuantityPieces,
    required this.discountValue,
    this.discountType = 'percent',
  });

  bool get isPercent => discountType == 'percent';

  factory ProductDiscount.fromJson(Map<String, dynamic> j) => ProductDiscount(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        minQuantityPieces: j['min_quantity_pieces'] as int,
        discountValue: (j['discount_percent'] as num).toDouble(),
        discountType: (j['discount_type'] as String?) ?? 'percent',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'min_quantity_pieces': minQuantityPieces,
        'discount_percent': discountValue,
        'discount_type': discountType,
      };
}
