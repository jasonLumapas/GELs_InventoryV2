import 'dart:convert';

class BadOrderDraftItem {
  final String productId;
  final int boxes;
  final int pieces;

  const BadOrderDraftItem({
    required this.productId,
    required this.boxes,
    required this.pieces,
  });

  factory BadOrderDraftItem.fromJson(Map<String, dynamic> j) =>
      BadOrderDraftItem(
        productId: j['product_id'] as String,
        boxes: (j['boxes'] as num?)?.toInt() ?? 0,
        pieces: (j['pieces'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'boxes': boxes,
        'pieces': pieces,
      };
}

class BadOrderDraft {
  final String id;
  final String type; // 'bad_order' | 'return'
  final String? clientId;
  final bool noClient;
  final DateTime date;
  final String? notes;
  final List<BadOrderDraftItem> items;
  final DateTime createdAt;

  const BadOrderDraft({
    required this.id,
    required this.type,
    this.clientId,
    this.noClient = false,
    required this.date,
    this.notes,
    required this.items,
    required this.createdAt,
  });

  factory BadOrderDraft.fromJson(Map<String, dynamic> j) => BadOrderDraft(
        id: j['id'] as String,
        type: j['type'] as String,
        clientId: j['client_id'] as String?,
        noClient: (j['no_client'] as bool?) ?? false,
        date: DateTime.parse(j['date'] as String),
        notes: j['notes'] as String?,
        items: (jsonDecode(j['items_json'] as String) as List)
            .map((e) => BadOrderDraftItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'client_id': clientId,
        'no_client': noClient,
        'date': date.toIso8601String(),
        'notes': notes,
        'items_json': jsonEncode(items.map((i) => i.toJson()).toList()),
        'created_at': createdAt.toIso8601String(),
      };
}
