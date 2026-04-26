import '../entities/package_request_entity.dart';
import '../../data/models/create_package_request_model.dart';

abstract class PackageRequestRepository {
  Future<List<PackageRequestEntity>> getAll();
  Future<PackageRequestEntity> getById(int id);
  Future<PackageRequestEntity> create(CreatePackageRequestModel request);
  Future<void> approve(int id);
  Future<void> reject(int id);
  Future<void> requestRevision(int id, String customerFeedback);
}
