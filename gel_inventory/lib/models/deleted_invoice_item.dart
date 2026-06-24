/// Audit record of an item removed from an invoice during editing
/// (`InvoiceRepository.editInvoice`). Preserved even after the invoice's
/// active item rows are replaced, so the removal can be reviewed later.
class DeletedInvoiceItem {
  final String id;
  final String invoiceId;
  final String productId;
  final String unitType; // 'box' | 'piece'
  final int quantity; // pieces
  final double pricePerPiece;
  final double subtotal;
  final bool isFree;
  final DateTime deletedAt;

  const DeletedInvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.unitType,
    required this.quantity,
    required this.pricePerPiece,
    required this.subtotal,
    required this.isFree,
    required this.deletedAt,
  });

  factory DeletedInvoiceItem.fromJson(Map<String, dynamic> j) =>
      DeletedInvoiceItem(
        id: j['id'] as String,
        invoiceId: j['invoice_id'] as String,
        productId: j['product_id'] as String,
        unitType: j['unit_type'] as String,
        quantity: (j['quantity'] as num).toInt(),
        pricePerPiece: (j['price_per_piece'] as num).toDouble(),
        subtotal: (j['subtotal'] as num).toDouble(),
        isFree: (j['is_free'] as bool?) ?? false,
        deletedAt: DateTime.parse(j['deleted_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_id': invoiceId,
        'product_id': productId,
        'unit_type': unitType,
        'quantity': quantity,
        'price_per_piece': pricePerPiece,
        'subtotal': subtotal,
        'is_free': isFree,
        'deleted_at': deletedAt.toIso8601String(),
      };
}
