class InvoicePayment {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime? paymentDate;
  final String? notes;
  final DateTime createdAt;

  const InvoicePayment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    this.paymentDate,
    this.notes,
    required this.createdAt,
  });

  factory InvoicePayment.fromJson(Map<String, dynamic> j) => InvoicePayment(
        id: j['id'] as String,
        invoiceId: j['invoice_id'] as String,
        amount: (j['amount'] as num).toDouble(),
        paymentDate: j['payment_date'] == null
            ? null
            : DateTime.parse(j['payment_date'] as String),
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_id': invoiceId,
        'amount': amount,
        'payment_date': paymentDate?.toIso8601String(),
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };
}
