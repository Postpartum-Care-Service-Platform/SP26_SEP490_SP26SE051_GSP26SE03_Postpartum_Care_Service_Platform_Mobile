import '../entities/home_staff_entity.dart';
import '../repositories/home_service_repository.dart';
import '../../data/datasources/home_service_remote_datasource.dart';

/// Get Free Home Staff Use Case
class GetFreeHomeStaffUsecase {
  final HomeServiceRepository repository;

  GetFreeHomeStaffUsecase(this.repository);

  Future<List<HomeStaffEntity>> call(
    List<StaffAvailabilityRequest> requests,
  ) async {
    return await repository.getFreeHomeStaffInDateList(requests);
  }
}
