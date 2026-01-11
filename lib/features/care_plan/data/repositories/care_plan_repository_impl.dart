import '../../domain/entities/care_plan_entity.dart';
import '../../domain/repositories/care_plan_repository.dart';
import '../datasources/care_plan_datasource.dart';

/// Care Plan Repository implementation - Data layer
class CarePlanRepositoryImpl implements CarePlanRepository {
  final CarePlanDataSource dataSource;

  CarePlanRepositoryImpl(this.dataSource);

  @override
  Future<List<CarePlanEntity>> getCarePlanDetailsByPackage(int packageId) async {
    final models = await dataSource.getCarePlanDetailsByPackage(packageId);
    return models.map((model) => model.toEntity()).toList();
  }
}
