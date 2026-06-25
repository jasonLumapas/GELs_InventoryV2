class SupplierReceivedInvoiceItem {
  final String id;
  final String receivedInvoiceId;
  final String productId;
  final String unitType; // 'box' | 'piece'
  final int quantity; // pieces
  final double systemPrice;
  final double supplierPrice;
  final double subtotalSystem;
  final double subtotalSupplier;
  final bool isFree;
  // Supplier price (per piece) as entered, before the invoice's
  // discounts/VAT were applied. Null for rows saved before this field
  // existed — callers should fall back to [supplierPrice] in that case.
  final double? rawSupplierPrice;

  const SupplierReceivedInvoiceItem({
    required this.id,
    required this.receivedInvoiceId,
    required this.productId,
    required this.unitType,
    required this.quantity,
    required this.systemPrice,
    required this.supplierPrice,
    required this.subtotalSystem,
    required this.subtotalSupplier,
    this.isFree = false,
    this.rawSupplierPrice,
  });

  factory SupplierReceivedInvoiceItem.fromJson(Map<String, dynamic> j) =>
      SupplierReceivedInvoiceItem(
        id: j['id'] as String,
        receivedInvoiceId: j['received_invoice_id'] as String,
        productId: j['product_id'] as String,
        unitType: j['unit_type'] as String,
        quantity: (j['quantity'] as num).toInt(),
        systemPrice: (j['system_price'] as num).toDouble(),
        supplierPrice: (j['supplier_price'] as num).toDouble(),
        subtotalSystem: (j['subtotal_system'] as num).toDouble(),
        subtotalSupplier: (j['subtotal_supplier'] as num).toDouble(),
        isFree: (j['is_free'] as bool?) ?? false,
        rawSupplierPrice: (j['raw_supplier_price'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'received_invoice_id': receivedInvoiceId,
        'product_id': productId,
        'unit_type': unitType,
        'quantity': quantity,
        'system_price': systemPrice,
        'supplier_price': supplierPrice,
        'subtotal_system': subtotalSystem,
        'subtotal_supplier': subtotalSupplier,
        'is_free': isFree,
        'raw_supplier_price': rawSupplierPrice,
      };
}
