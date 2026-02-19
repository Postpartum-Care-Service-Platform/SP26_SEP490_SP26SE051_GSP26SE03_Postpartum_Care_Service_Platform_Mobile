import '../entities/package_type_entity.dart';
import '../repositories/package_type_repository.dart';

/// Get package types use case
class GetPackageTypesUsecase {
  final PackageTypeRepository repository;

  GetPackageTypesUsecase(this.repository);

  Future<List<PackageTypeEntity>> call() async {
    return await repository.getPackageTypes();
  }
}
