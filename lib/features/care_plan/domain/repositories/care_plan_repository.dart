import '../entities/care_plan_entity.dart';

/// Care Plan Repository interface - Domain layer
abstract class CarePlanRepository {
  /// Get care plan details by package ID
  Future<List<CarePlanEntity>> getCarePlanDetailsByPackage(int packageId);
}
