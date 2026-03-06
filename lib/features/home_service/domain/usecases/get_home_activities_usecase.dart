import '../entities/home_activity_entity.dart';
import '../repositories/home_service_repository.dart';

/// Get Home Activities Use Case
class GetHomeActivitiesUsecase {
  final HomeServiceRepository repository;

  GetHomeActivitiesUsecase(this.repository);

  Future<List<HomeActivityEntity>> call() async {
    return await repository.getHomeActivities();
  }
}
