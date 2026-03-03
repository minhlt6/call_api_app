import 'package:firebase_database/firebase_database.dart';
import '../models/food_model.dart';

class FirebaseService {
  final _dbRef = FirebaseDatabase.instance.ref();

  Future<List<Food>> fetchFoods() async {
    try {
      final snapshot = await _dbRef.child('foods').get();
      
      if (snapshot.exists) {
        List<Food> foods = [];
        // Parse dữ liệu trả về thành dạng Map
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          foods.add(Food.fromJson(key.toString(), value as Map<dynamic, dynamic>));
        });
        return foods;
      } else {
        return []; // Trả về mảng rỗng nếu không có dữ liệu
      }
    } catch (e) {
      throw Exception('Lỗi khi tải dữ liệu từ máy chủ: $e');
    }
  }
}