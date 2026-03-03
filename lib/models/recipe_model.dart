class Recipe {
  final int id;
  final String name;
  final String image;
  final String cuisine;

  Recipe({
    required this.id,
    required this.name,
    required this.image,
    required this.cuisine,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      cuisine: json['cuisine'],
    );
  }
}