class Client {
  final String id;
  final String name;
  final String? contact;
  final String? address;
  final bool isBlacklisted;
  final DateTime createdAt;

  const Client({
    required this.id,
    required this.name,
    this.contact,
    this.address,
    this.isBlacklisted = false,
    required this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> j) => Client(
        id: j['id'] as String,
        name: j['name'] as String,
        contact: j['contact'] as String?,
        address: j['address'] as String?,
        isBlacklisted: (j['is_blacklisted'] as bool?) ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contact': contact,
        'address': address,
        'is_blacklisted': isBlacklisted,
        'created_at': createdAt.toIso8601String(),
      };

  Client copyWith({
    String? name,
    String? contact,
    String? address,
    bool? isBlacklisted,
  }) =>
      Client(
        id: id,
        name: name ?? this.name,
        contact: contact ?? this.contact,
        address: address ?? this.address,
        isBlacklisted: isBlacklisted ?? this.isBlacklisted,
        createdAt: createdAt,
      );
}
