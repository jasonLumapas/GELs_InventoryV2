class Invoice {
  final String id;
  final String clientId;
  final DateTime invoiceDate;
  final double totalAmount;
  final String status;       // draft | printed | cancelled
  final DateTime createdAt;
  final String? invoiceNumber;
  final int? sequenceNumber; // permanent sequential display number (0, 1, 2, ...)
  final String invoiceType;  // delivery | walk_in
  final String paymentType;   // cash | check | credit | partial
  final double? partialAmount;
  final DateTime? partialDate;
  final String?   checkReference;
  final double?   checkAmount;
  final DateTime? checkIssuedDate;
  final DateTime? checkDueDate;
  final String?   notes; // internal note — never shown on the printed invoice
  final double?   actualAmount; // optional actual amount on referenced receipt
  final bool      includeInLayout; // whether this invoice counts in the Layout screen

  const Invoice({
    required this.id,
    required this.clientId,
    required this.invoiceDate,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.invoiceNumber,
    this.sequenceNumber,
    this.invoiceType = 'delivery',
    this.paymentType = 'cash',
    this.partialAmount,
    this.partialDate,
    this.checkReference,
    this.checkAmount,
    this.checkIssuedDate,
    this.checkDueDate,
    this.notes,
    this.actualAmount,
    this.includeInLayout = true,
  });

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
        id: j['id'] as String,
        clientId: j['client_id'] as String,
        invoiceDate: DateTime.parse(j['invoice_date'] as String),
        totalAmount: (j['total_amount'] as num).toDouble(),
        status: j['status'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        invoiceNumber: j['invoice_number'] as String?,
        sequenceNumber: (j['sequence_number'] as num?)?.toInt(),
        invoiceType:    (j['invoice_type'] as String?) ?? 'delivery',
        paymentType:    (j['payment_type'] as String?) ?? 'cash',
        partialAmount:   (j['partial_amount'] as num?)?.toDouble(),
        partialDate:     j['partial_date'] == null
            ? null
            : DateTime.parse(j['partial_date'] as String),
        checkReference:  j['check_reference'] as String?,
        checkAmount:     (j['check_amount'] as num?)?.toDouble(),
        checkIssuedDate: j['check_issued_date'] == null
            ? null
            : DateTime.parse(j['check_issued_date'] as String),
        checkDueDate:    j['check_due_date'] == null
            ? null
            : DateTime.parse(j['check_due_date'] as String),
        notes: j['notes'] as String?,
        actualAmount: (j['actual_amount'] as num?)?.toDouble(),
        includeInLayout: (j['include_in_layout'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_id': clientId,
        'invoice_date': invoiceDate.toIso8601String(),
        'total_amount': totalAmount,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'invoice_number': invoiceNumber,
        'sequence_number': sequenceNumber,
        'invoice_type':   invoiceType,
        'payment_type':   paymentType,
        'partial_amount':  partialAmount,
        'partial_date':    partialDate?.toIso8601String(),
        'check_reference': checkReference,
        'check_amount':    checkAmount,
        'check_issued_date': checkIssuedDate?.toIso8601String(),
        'check_due_date':  checkDueDate?.toIso8601String(),
        'notes': notes,
        'actual_amount': actualAmount,
        'include_in_layout': includeInLayout,
      };

  String get displayNumber => sequenceNumber != null
      ? sequenceNumber!.toString().padLeft(8, '0')
      : (invoiceNumber ?? 'INV-${id.substring(0, 8).toUpperCase()}');

  bool get isDelivery => invoiceType == 'delivery';

  String get paymentLabel {
    switch (paymentType) {
      case 'check':   return 'Check';
      case 'credit':  return 'Credit';
      case 'partial': return 'Partial';
      default:        return 'Cash';
    }
  }

  Invoice copyWith({
    double? totalAmount,
    String? status,
    String? clientId,
    DateTime? invoiceDate,
    String? invoiceNumber,
    Object? sequenceNumber = _sentinel,
    String? invoiceType,
    String? paymentType,
    Object? partialAmount  = _sentinel,
    Object? partialDate    = _sentinel,
    Object? checkReference = _sentinel,
    Object? checkAmount    = _sentinel,
    Object? checkIssuedDate = _sentinel,
    Object? checkDueDate   = _sentinel,
    Object? notes          = _sentinel,
    Object? actualAmount   = _sentinel,
    bool? includeInLayout,
  }) =>
      Invoice(
        id: id,
        clientId: clientId ?? this.clientId,
        invoiceDate: invoiceDate ?? this.invoiceDate,
        totalAmount: totalAmount ?? this.totalAmount,
        status: status ?? this.status,
        createdAt: createdAt,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        sequenceNumber: sequenceNumber == _sentinel
            ? this.sequenceNumber
            : sequenceNumber as int?,
        invoiceType: invoiceType ?? this.invoiceType,
        paymentType: paymentType ?? this.paymentType,
        partialAmount: partialAmount == _sentinel
            ? this.partialAmount
            : partialAmount as double?,
        partialDate: partialDate == _sentinel
            ? this.partialDate
            : partialDate as DateTime?,
        checkReference: checkReference == _sentinel
            ? this.checkReference
            : checkReference as String?,
        checkAmount: checkAmount == _sentinel
            ? this.checkAmount
            : checkAmount as double?,
        checkIssuedDate: checkIssuedDate == _sentinel
            ? this.checkIssuedDate
            : checkIssuedDate as DateTime?,
        checkDueDate: checkDueDate == _sentinel
            ? this.checkDueDate
            : checkDueDate as DateTime?,
        notes: notes == _sentinel ? this.notes : notes as String?,
        actualAmount: actualAmount == _sentinel
            ? this.actualAmount
            : actualAmount as double?,
        includeInLayout: includeInLayout ?? this.includeInLayout,
      );
}

const Object _sentinel = Object();
