class VanArea {
  final String id;
  final String name;

  const VanArea({required this.id, required this.name});

  factory VanArea.fromJson(Map<String, dynamic> j) => VanArea(
        id: j['id'] as String,
        name: j['name'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
