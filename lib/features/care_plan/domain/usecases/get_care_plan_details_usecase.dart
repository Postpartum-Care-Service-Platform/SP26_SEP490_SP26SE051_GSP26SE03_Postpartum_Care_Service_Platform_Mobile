import '../entities/care_plan_entity.dart';
import '../repositories/care_plan_repository.dart';

/// Get care plan details use case
class GetCarePlanDetailsUsecase {
  final CarePlanRepository repository;

  GetCarePlanDetailsUsecase(this.repository);

  Future<List<CarePlanEntity>> call(int packageId) async {
    return await repository.getCarePlanDetailsByPackage(packageId);
  }
}
