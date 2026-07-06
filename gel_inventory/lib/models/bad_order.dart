class BadOrder {
  final String id;
  final String clientId;
  final DateTime date;
  final String type; // 'bad_order' | 'return' | 'stock_release'
  final String? notes;
  final DateTime createdAt;

  const BadOrder({
    required this.id,
    required this.clientId,
    required this.date,
    required this.type,
    this.notes,
    required this.createdAt,
  });

  factory BadOrder.fromJson(Map<String, dynamic> j) => BadOrder(
        id: j['id'] as String,
        clientId: j['client_id'] as String,
        date: DateTime.parse(j['date'] as String),
        type: j['type'] as String,
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_id': clientId,
        'date': date.toIso8601String(),
        'type': type,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  bool get isReturn => type == 'return';
  bool get isStockRelease => type == 'stock_release';
  String get typeLabel {
    if (isReturn) return 'Return';
    if (isStockRelease) return 'Stock Release';
    return 'Bad Order';
  }
}
