class BadOrder {
  final String id;
  final String clientId;
  final DateTime date;
  final String type; // 'bad_order' | 'return' | 'stock_release' | 'stock_pulled_out'
  final String? notes;
  final DateTime createdAt;
  // 'stock_pulled_out' only: the invoice this entry is linked to.
  final String? invoiceId;

  const BadOrder({
    required this.id,
    required this.clientId,
    required this.date,
    required this.type,
    this.notes,
    required this.createdAt,
    this.invoiceId,
  });

  factory BadOrder.fromJson(Map<String, dynamic> j) => BadOrder(
        id: j['id'] as String,
        clientId: j['client_id'] as String,
        date: DateTime.parse(j['date'] as String),
        type: j['type'] as String,
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        invoiceId: j['invoice_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_id': clientId,
        'date': date.toIso8601String(),
        'type': type,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'invoice_id': invoiceId,
      };

  bool get isReturn => type == 'return';
  bool get isStockRelease => type == 'stock_release';
  bool get isStockPulledOut => type == 'stock_pulled_out';
  // Stock pulled out was never actually delivered, so — like a return — it
  // goes back into inventory rather than being deducted.
  bool get restoresInventory => isReturn || isStockPulledOut;
  String get typeLabel {
    if (isReturn) return 'Return';
    if (isStockRelease) return 'Stock Release';
    if (isStockPulledOut) return 'Stock Pulled out';
    return 'Bad Order';
  }
}
