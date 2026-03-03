import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class ApiService {
  // Thay đổi URL thành một đường link sai (ví dụ: dummyjson.com/recipes_error) 
  // để giả lập tình huống lỗi mạng khi cần test[cite: 14].
  static const String _url = 'https://dummyjson.com/recipes?limit=15';

  Future<List<Recipe>> fetchRecipes() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> recipesJson = data['recipes'];
        return recipesJson.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi kết nối từ máy chủ');
      }
    } catch (e) {
      throw Exception('Lỗi mạng hoặc không thể kết nối: $e');
    }
  }
}