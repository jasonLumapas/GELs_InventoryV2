class ProductDiscount {
  final String id;
  final String productId;
  final int minQuantityPieces;
  final double discountValue; // percent (0-100) or fixed currency amount
  final String discountType; // 'percent' | 'amount' | 'buy_x_get_y'
  // Free quantity (in pieces) granted once minQuantityPieces is reached.
  // Only meaningful when discountType == 'buy_x_get_y'.
  final int? freeQuantityPieces;

  const ProductDiscount({
    required this.id,
    required this.productId,
    required this.minQuantityPieces,
    required this.discountValue,
    this.discountType = 'percent',
    this.freeQuantityPieces,
  });

  bool get isPercent => discountType == 'percent';
  bool get isBuyXGetY => discountType == 'buy_x_get_y';

  factory ProductDiscount.fromJson(Map<String, dynamic> j) => ProductDiscount(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        minQuantityPieces: j['min_quantity_pieces'] as int,
        discountValue: (j['discount_percent'] as num).toDouble(),
        discountType: (j['discount_type'] as String?) ?? 'percent',
        freeQuantityPieces: j['free_quantity_pieces'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'min_quantity_pieces': minQuantityPieces,
        'discount_percent': discountValue,
        'discount_type': discountType,
        'free_quantity_pieces': freeQuantityPieces,
      };
}
