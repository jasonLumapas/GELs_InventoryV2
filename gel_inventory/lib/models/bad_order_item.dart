class BadOrderItem {
  final String id;
  final String badOrderId;
  final String productId;
  final String unitType; // 'box' | 'piece'
  final int quantity;

  const BadOrderItem({
    required this.id,
    required this.badOrderId,
    required this.productId,
    required this.unitType,
    required this.quantity,
  });

  factory BadOrderItem.fromJson(Map<String, dynamic> j) => BadOrderItem(
        id: j['id'] as String,
        badOrderId: j['bad_order_id'] as String,
        productId: j['product_id'] as String,
        unitType: j['unit_type'] as String,
        quantity: j['quantity'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bad_order_id': badOrderId,
        'product_id': productId,
        'unit_type': unitType,
        'quantity': quantity,
      };
}
