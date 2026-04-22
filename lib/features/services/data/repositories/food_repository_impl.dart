import '../../domain/entities/food_entity.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/food_remote_datasource.dart';

/// Food Repository Implementation - Data layer
class FoodRepositoryImpl implements FoodRepository {
  final FoodRemoteDataSource remoteDataSource;

  FoodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FoodEntity>> getFoods() async {
    return await remoteDataSource.getFoods();
  }
}
