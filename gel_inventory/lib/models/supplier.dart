class Supplier {
  final String id;
  final String name;
  final String? contact;
  final String? address;
  final DateTime createdAt;

  const Supplier({
    required this.id,
    required this.name,
    this.contact,
    this.address,
    required this.createdAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> j) => Supplier(
        id: j['id'] as String,
        name: j['name'] as String,
        contact: j['contact'] as String?,
        address: j['address'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contact': contact,
        'address': address,
        'created_at': createdAt.toIso8601String(),
      };

  Supplier copyWith({
    String? name,
    String? contact,
    String? address,
  }) =>
      Supplier(
        id: id,
        name: name ?? this.name,
        contact: contact ?? this.contact,
        address: address ?? this.address,
        createdAt: createdAt,
      );
}
