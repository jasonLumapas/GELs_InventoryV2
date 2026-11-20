class PurchaseOrderItem {
  final String id;
  final String purchaseOrderId;
  final String productId;
  // Product's withdrawal price (per box) at the time the item was added —
  // kept for reference/comparison against the supplier's quoted price.
  final double systemPrice;
  final double price;
  final double cases;
  final double amount;
  final bool isFree;
  // Supplier price (per box) before the order's discounts/VAT were applied.
  // Null for rows saved before this field existed — callers should fall back
  // to [price] in that case.
  final double? rawPrice;

  const PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.productId,
    this.systemPrice = 0,
    required this.price,
    required this.cases,
    required this.amount,
    this.isFree = false,
    this.rawPrice,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> j) =>
      PurchaseOrderItem(
        id: j['id'] as String,
        purchaseOrderId: j['purchase_order_id'] as String,
        productId: j['product_id'] as String,
        systemPrice: (j['system_price'] as num?)?.toDouble() ?? 0,
        price: (j['price'] as num).toDouble(),
        cases: (j['cases'] as num).toDouble(),
        amount: (j['amount'] as num).toDouble(),
        isFree: (j['is_free'] as bool?) ?? false,
        rawPrice: (j['raw_price'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'purchase_order_id': purchaseOrderId,
        'product_id': productId,
        'system_price': systemPrice,
        'price': price,
        'cases': cases,
        'amount': amount,
        'is_free': isFree,
        'raw_price': rawPrice,
      };
}
