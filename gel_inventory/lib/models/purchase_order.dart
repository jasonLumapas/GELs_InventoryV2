class PurchaseOrder {
  final String id;
  final String supplierId;
  final DateTime orderDate;
  final String? referenceNumber;
  final double totalAmount;
  final String status; // 'open' | 'cancelled'
  final String? notes;
  final DateTime createdAt;
  // Cascading discount percentages applied (in order) to every item's
  // price, e.g. [10, 5] = 10% off, then 5% off the result.
  final List<double> discountPercents;
  final bool vatEnabled; // applies 12% VAT on top of the discounted price

  const PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.orderDate,
    this.referenceNumber,
    this.totalAmount = 0,
    this.status = 'open',
    this.notes,
    required this.createdAt,
    this.discountPercents = const [],
    this.vatEnabled = false,
  });

  /// Decodes the comma-separated "discount_percents" column, e.g. "10,5".
  static List<double> decodeDiscountPercents(String? raw) =>
      (raw == null || raw.isEmpty)
          ? const []
          : raw.split(',').map((s) => double.parse(s)).toList();

  /// Encodes a discount list back to the comma-separated storage format.
  static String? encodeDiscountPercents(List<double> discounts) =>
      discounts.isEmpty ? null : discounts.map((d) => d.toString()).join(',');

  factory PurchaseOrder.fromJson(Map<String, dynamic> j) => PurchaseOrder(
        id: j['id'] as String,
        supplierId: j['supplier_id'] as String,
        orderDate: DateTime.parse(j['order_date'] as String),
        referenceNumber: j['reference_number'] as String?,
        totalAmount: (j['total_amount'] as num?)?.toDouble() ?? 0,
        status: (j['status'] as String?) ?? 'open',
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        discountPercents:
            decodeDiscountPercents(j['discount_percents'] as String?),
        vatEnabled: (j['vat_enabled'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'supplier_id': supplierId,
        'order_date': orderDate.toIso8601String(),
        'reference_number': referenceNumber,
        'total_amount': totalAmount,
        'status': status,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'discount_percents': encodeDiscountPercents(discountPercents),
        'vat_enabled': vatEnabled,
      };

  String get displayNumber =>
      referenceNumber ?? 'PO-${id.substring(0, 8).toUpperCase()}';

  PurchaseOrder copyWith({
    String? supplierId,
    DateTime? orderDate,
    Object? referenceNumber = _sentinel,
    double? totalAmount,
    String? status,
    Object? notes = _sentinel,
    List<double>? discountPercents,
    bool? vatEnabled,
  }) =>
      PurchaseOrder(
        id: id,
        supplierId: supplierId ?? this.supplierId,
        orderDate: orderDate ?? this.orderDate,
        referenceNumber: referenceNumber == _sentinel
            ? this.referenceNumber
            : referenceNumber as String?,
        totalAmount: totalAmount ?? this.totalAmount,
        status: status ?? this.status,
        notes: notes == _sentinel ? this.notes : notes as String?,
        createdAt: createdAt,
        discountPercents: discountPercents ?? this.discountPercents,
        vatEnabled: vatEnabled ?? this.vatEnabled,
      );
}

const Object _sentinel = Object();
