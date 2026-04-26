import '../../../auth/data/models/current_account_model.dart';
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

class GetNowPackageUsecase {
  final PackageRepository repository;

  GetNowPackageUsecase(this.repository);

  Future<NowPackageModel> call() async {
    return await repository.getNowPackage();
  }
}

class GetMyCustomPackagesUsecase {
  final PackageRepository repository;

  GetMyCustomPackagesUsecase(this.repository);

  Future<List<PackageEntity>> call() async {
    return await repository.getMyCustomPackages();
  }
}
