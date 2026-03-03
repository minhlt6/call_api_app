import 'package:flutter/material.dart';
import '../models/food_model.dart';

class FoodDetailScreen extends StatelessWidget {
  final Food food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(food.name), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  food.imageUrl,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.fastfood, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              food.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              food.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Giá: ${food.price} đ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(food.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text(
              'Nguyên liệu:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              food.ingredients.isNotEmpty
                  ? food.ingredients
                  : 'Không có thông tin nguyên liệu',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            // Additional fields (if any) can be shown here.
          ],
        ),
      ),
    );
  }
}
