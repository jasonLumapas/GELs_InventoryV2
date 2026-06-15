import 'dart:convert';

class VanStockDraftItem {
  final String productId;
  final String unitType; // 'box' | 'piece'
  final int quantity;

  const VanStockDraftItem({
    required this.productId,
    required this.unitType,
    required this.quantity,
  });

  factory VanStockDraftItem.fromJson(Map<String, dynamic> j) =>
      VanStockDraftItem(
        productId: j['product_id'] as String,
        unitType: j['unit_type'] as String,
        quantity: (j['quantity'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'unit_type': unitType,
        'quantity': quantity,
      };
}

class VanStockDraft {
  final String id;
  final String type; // 'out' | 'in'
  final String? areaId;
  final DateTime txDate;
  final List<VanStockDraftItem> items;
  final DateTime createdAt;

  const VanStockDraft({
    required this.id,
    required this.type,
    this.areaId,
    required this.txDate,
    required this.items,
    required this.createdAt,
  });

  factory VanStockDraft.fromJson(Map<String, dynamic> j) => VanStockDraft(
        id: j['id'] as String,
        type: j['type'] as String,
        areaId: j['area_id'] as String?,
        txDate: DateTime.parse(j['tx_date'] as String),
        items: (jsonDecode(j['items_json'] as String) as List)
            .map((e) => VanStockDraftItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'area_id': areaId,
        'tx_date': txDate.toIso8601String(),
        'items_json': jsonEncode(items.map((i) => i.toJson()).toList()),
        'created_at': createdAt.toIso8601String(),
      };
}
