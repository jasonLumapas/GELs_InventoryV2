class Product {
  final String id;
  final String name;
  final String supplierId;
  final int piecesPerBox;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.supplierId,
    required this.piecesPerBox,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        supplierId: j['supplier_id'] as String,
        piecesPerBox: j['pieces_per_box'] as int,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'supplier_id': supplierId,
        'pieces_per_box': piecesPerBox,
        'created_at': createdAt.toIso8601String(),
      };

  Product copyWith({String? name, String? supplierId, int? piecesPerBox}) =>
      Product(
        id: id,
        name: name ?? this.name,
        supplierId: supplierId ?? this.supplierId,
        piecesPerBox: piecesPerBox ?? this.piecesPerBox,
        createdAt: createdAt,
      );
}
