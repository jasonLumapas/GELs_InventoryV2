class PurchaseOrderItem {
  final String id;
  final String purchaseOrderId;
  final String productId;
  final double price;
  final double cases;
  final double amount;

  const PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.productId,
    required this.price,
    required this.cases,
    required this.amount,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> j) =>
      PurchaseOrderItem(
        id: j['id'] as String,
        purchaseOrderId: j['purchase_order_id'] as String,
        productId: j['product_id'] as String,
        price: (j['price'] as num).toDouble(),
        cases: (j['cases'] as num).toDouble(),
        amount: (j['amount'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'purchase_order_id': purchaseOrderId,
        'product_id': productId,
        'price': price,
        'cases': cases,
        'amount': amount,
      };
}
