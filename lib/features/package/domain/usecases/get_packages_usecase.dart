import '../entities/package_entity.dart';
import '../repositories/package_repository.dart';

/// Get packages use case
class GetPackagesUsecase {
  final PackageRepository repository;

  GetPackagesUsecase(this.repository);

  Future<List<PackageEntity>> call() async {
    return await repository.getPackages();
  }
}
