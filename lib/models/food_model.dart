class Food {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String ingredients;
  final int price;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.price,
  });

  // Chuyển đổi dữ liệu Map từ Realtime Database thành Model
  factory Food.fromJson(String key, Map<dynamic, dynamic> json) {
    return Food(
      id: key,
      name: json['name'] ?? 'Chưa có tên',
      description: json['description'] ?? 'Chưa có mô tả',
      imageUrl: json['imageUrl'] ?? '',
      ingredients: json['ingredients'] ?? '',
      price: (json['price'] is int)
          ? json['price'] as int
          : int.tryParse('${json['price']}') ?? 0,
    );
  }
}
