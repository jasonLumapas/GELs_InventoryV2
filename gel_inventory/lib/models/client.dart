class Client {
  final String id;
  final String name;
  final String? contact;
  final String? address;
  final DateTime createdAt;

  const Client({
    required this.id,
    required this.name,
    this.contact,
    this.address,
    required this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> j) => Client(
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

  Client copyWith({String? name, String? contact, String? address}) => Client(
        id: id,
        name: name ?? this.name,
        contact: contact ?? this.contact,
        address: address ?? this.address,
        createdAt: createdAt,
      );
}
