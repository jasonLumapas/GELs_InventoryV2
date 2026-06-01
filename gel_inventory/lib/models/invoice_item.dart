class InvoiceItem {
  final String id;
  final String invoiceId;
  final String productId;
  final String unitType; // 'box' | 'piece'
  final int quantity;
  final double pricePerPiece;
  final double subtotal;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.unitType,
    required this.quantity,
    required this.pricePerPiece,
    required this.subtotal,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> j) => InvoiceItem(
        id: j['id'] as String,
        invoiceId: j['invoice_id'] as String,
        productId: j['product_id'] as String,
        unitType: j['unit_type'] as String,
        quantity: j['quantity'] as int,
        pricePerPiece: (j['price_per_piece'] as num).toDouble(),
        subtotal: (j['subtotal'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_id': invoiceId,
        'product_id': productId,
        'unit_type': unitType,
        'quantity': quantity,
        'price_per_piece': pricePerPiece,
        'subtotal': subtotal,
      };
}
