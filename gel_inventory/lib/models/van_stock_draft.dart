import 'dart:convert';

class VanStockDraftItem {
  final String productId;
  final int boxes;
  final int pieces;

  const VanStockDraftItem({
    required this.productId,
    required this.boxes,
    required this.pieces,
  });

  factory VanStockDraftItem.fromJson(Map<String, dynamic> j) {
    if (j.containsKey('boxes') || j.containsKey('pieces')) {
      return VanStockDraftItem(
        productId: j['product_id'] as String,
        boxes: (j['boxes'] as num?)?.toInt() ?? 0,
        pieces: (j['pieces'] as num?)?.toInt() ?? 0,
      );
    }
    // Legacy drafts saved before boxes+pieces could be entered together.
    final legacyUnitType = j['unit_type'] as String? ?? 'box';
    final legacyQuantity = (j['quantity'] as num?)?.toInt() ?? 0;
    return VanStockDraftItem(
      productId: j['product_id'] as String,
      boxes: legacyUnitType == 'box' ? legacyQuantity : 0,
      pieces: legacyUnitType == 'piece' ? legacyQuantity : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'boxes': boxes,
        'pieces': pieces,
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
