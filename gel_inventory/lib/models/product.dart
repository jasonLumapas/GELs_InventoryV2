class Product {
  final String id;
  final String name;
  final String? productCode;
  final String supplierId;
  final int piecesPerBox;
  final DateTime createdAt;
  // Minimum stock (in pieces) below which the product is flagged for reorder.
  final int? reorderPoint;
  // Fixed reorder batch size (in pieces). When null, the suggested quantity
  // is computed from recent sales velocity instead.
  final int? reorderQuantity;

  const Product({
    required this.id,
    required this.name,
    this.productCode,
    required this.supplierId,
    required this.piecesPerBox,
    required this.createdAt,
    this.reorderPoint,
    this.reorderQuantity,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        productCode: j['product_code'] as String?,
        supplierId: j['supplier_id'] as String,
        piecesPerBox: j['pieces_per_box'] as int,
        createdAt: DateTime.parse(j['created_at'] as String),
        reorderPoint: j['reorder_point'] as int?,
        reorderQuantity: j['reorder_quantity'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'product_code': productCode,
        'supplier_id': supplierId,
        'pieces_per_box': piecesPerBox,
        'created_at': createdAt.toIso8601String(),
        'reorder_point': reorderPoint,
        'reorder_quantity': reorderQuantity,
      };

  Product copyWith(
          {String? name,
          String? productCode,
          String? supplierId,
          int? piecesPerBox}) =>
      Product(
        id: id,
        name: name ?? this.name,
        productCode: productCode ?? this.productCode,
        supplierId: supplierId ?? this.supplierId,
        piecesPerBox: piecesPerBox ?? this.piecesPerBox,
        createdAt: createdAt,
        reorderPoint: reorderPoint,
        reorderQuantity: reorderQuantity,
      );
}
