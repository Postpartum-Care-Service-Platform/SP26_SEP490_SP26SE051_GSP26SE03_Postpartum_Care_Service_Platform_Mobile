import '../../../auth/data/models/current_account_model.dart';
import '../../domain/entities/package_entity.dart';
import '../../domain/repositories/package_repository.dart';
import '../datatsources/package_remote_datasource.dart';

/// Package repository implementation - Data layer
class PackageRepositoryImpl implements PackageRepository {
  final PackageRemoteDataSource dataSource;

  PackageRepositoryImpl(this.dataSource);

  @override
  Future<List<PackageEntity>> getPackages() async {
    final models = await dataSource.getPackages();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<PackageEntity> getPackageById(int id) async {
    final model = await dataSource.getPackageById(id);
    return model.toEntity();
  }

  @override
  Future<NowPackageModel> getNowPackage() async {
    return dataSource.getNowPackage();
  }
}
