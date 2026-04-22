import '../entities/food_entity.dart';

/// Food Repository Interface - Domain layer
abstract class FoodRepository {
  /// Get all available foods
  Future<List<FoodEntity>> getFoods();
}
