class Invoice {
  final String id;
  final String clientId;
  final DateTime invoiceDate;
  final double totalAmount;
  final String status; // draft | printed | cancelled
  final DateTime createdAt;
  final String? invoiceNumber;
  final String invoiceType; // delivery | walk_in

  const Invoice({
    required this.id,
    required this.clientId,
    required this.invoiceDate,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.invoiceNumber,
    this.invoiceType = 'delivery',
  });

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
        id: j['id'] as String,
        clientId: j['client_id'] as String,
        invoiceDate: DateTime.parse(j['invoice_date'] as String),
        totalAmount: (j['total_amount'] as num).toDouble(),
        status: j['status'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        invoiceNumber: j['invoice_number'] as String?,
        invoiceType: (j['invoice_type'] as String?) ?? 'delivery',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_id': clientId,
        'invoice_date': invoiceDate.toIso8601String(),
        'total_amount': totalAmount,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'invoice_number': invoiceNumber,
        'invoice_type': invoiceType,
      };

  String get displayNumber =>
      invoiceNumber ?? 'INV-${id.substring(0, 8).toUpperCase()}';

  bool get isDelivery => invoiceType == 'delivery';

  Invoice copyWith({
    double? totalAmount,
    String? status,
    String? clientId,
    DateTime? invoiceDate,
    String? invoiceNumber,
    String? invoiceType,
  }) =>
      Invoice(
        id: id,
        clientId: clientId ?? this.clientId,
        invoiceDate: invoiceDate ?? this.invoiceDate,
        totalAmount: totalAmount ?? this.totalAmount,
        status: status ?? this.status,
        createdAt: createdAt,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        invoiceType: invoiceType ?? this.invoiceType,
      );
}
