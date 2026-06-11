class PurchaseOrder {
  final String id;
  final String supplierId;
  final DateTime orderDate;
  final String? referenceNumber;
  final double totalAmount;
  final String status; // 'open' | 'cancelled'
  final String? notes;
  final DateTime createdAt;

  const PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.orderDate,
    this.referenceNumber,
    this.totalAmount = 0,
    this.status = 'open',
    this.notes,
    required this.createdAt,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> j) => PurchaseOrder(
        id: j['id'] as String,
        supplierId: j['supplier_id'] as String,
        orderDate: DateTime.parse(j['order_date'] as String),
        referenceNumber: j['reference_number'] as String?,
        totalAmount: (j['total_amount'] as num?)?.toDouble() ?? 0,
        status: (j['status'] as String?) ?? 'open',
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
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
      );
}

const Object _sentinel = Object();
