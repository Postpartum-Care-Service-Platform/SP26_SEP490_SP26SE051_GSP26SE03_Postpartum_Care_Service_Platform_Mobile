import '../entities/food_entity.dart';
import '../repositories/food_repository.dart';

class GetFoodsUseCase {
  final FoodRepository repository;

  GetFoodsUseCase(this.repository);

  Future<List<FoodEntity>> call() async {
    return await repository.getFoods();
  }
}
