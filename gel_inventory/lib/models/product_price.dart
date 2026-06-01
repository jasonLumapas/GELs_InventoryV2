class ProductPrice {
  final String id;
  final String productId;
  final double withdrawalPrice;
  final double sellingPrice;
  final DateTime effectiveFrom;

  const ProductPrice({
    required this.id,
    required this.productId,
    required this.withdrawalPrice,
    required this.sellingPrice,
    required this.effectiveFrom,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> j) => ProductPrice(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        withdrawalPrice: (j['withdrawal_price'] as num).toDouble(),
        sellingPrice: (j['selling_price'] as num).toDouble(),
        effectiveFrom: DateTime.parse(j['effective_from'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'withdrawal_price': withdrawalPrice,
        'selling_price': sellingPrice,
        'effective_from': effectiveFrom.toIso8601String(),
      };
}
