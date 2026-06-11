class SupplierReceivedInvoice {
  final String id;
  final String supplierId;
  final DateTime receivedDate;
  final String? referenceNumber;
  final double totalAmountSystem;
  final double totalAmountSupplier;
  final String status; // 'received' | 'cancelled'
  final String? notes;
  final DateTime createdAt;

  const SupplierReceivedInvoice({
    required this.id,
    required this.supplierId,
    required this.receivedDate,
    this.referenceNumber,
    this.totalAmountSystem = 0,
    this.totalAmountSupplier = 0,
    this.status = 'received',
    this.notes,
    required this.createdAt,
  });

  factory SupplierReceivedInvoice.fromJson(Map<String, dynamic> j) =>
      SupplierReceivedInvoice(
        id: j['id'] as String,
        supplierId: j['supplier_id'] as String,
        receivedDate: DateTime.parse(j['received_date'] as String),
        referenceNumber: j['reference_number'] as String?,
        totalAmountSystem: (j['total_amount_system'] as num?)?.toDouble() ?? 0,
        totalAmountSupplier:
            (j['total_amount_supplier'] as num?)?.toDouble() ?? 0,
        status: (j['status'] as String?) ?? 'received',
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'supplier_id': supplierId,
        'received_date': receivedDate.toIso8601String(),
        'reference_number': referenceNumber,
        'total_amount_system': totalAmountSystem,
        'total_amount_supplier': totalAmountSupplier,
        'status': status,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  String get displayNumber =>
      referenceNumber ?? 'SRI-${id.substring(0, 8).toUpperCase()}';

  SupplierReceivedInvoice copyWith({
    String? supplierId,
    DateTime? receivedDate,
    Object? referenceNumber = _sentinel,
    double? totalAmountSystem,
    double? totalAmountSupplier,
    String? status,
    Object? notes = _sentinel,
  }) =>
      SupplierReceivedInvoice(
        id: id,
        supplierId: supplierId ?? this.supplierId,
        receivedDate: receivedDate ?? this.receivedDate,
        referenceNumber: referenceNumber == _sentinel
            ? this.referenceNumber
            : referenceNumber as String?,
        totalAmountSystem: totalAmountSystem ?? this.totalAmountSystem,
        totalAmountSupplier: totalAmountSupplier ?? this.totalAmountSupplier,
        status: status ?? this.status,
        notes: notes == _sentinel ? this.notes : notes as String?,
        createdAt: createdAt,
      );
}

const Object _sentinel = Object();
