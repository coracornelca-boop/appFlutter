class Recipe {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String userId;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.userId,
    required this.createdAt,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['image_url'],
      userId: map['user_id'].toString(),
      createdAt: DateTime.parse(map['created_at'].toString()),
    );
  }
}