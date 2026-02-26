import '../../domain/entities/package_type_entity.dart';
import '../../domain/repositories/package_type_repository.dart';
import '../datatsources/package_type_remote_datasource.dart';

/// Package Type repository implementation - Data layer
class PackageTypeRepositoryImpl implements PackageTypeRepository {
  final PackageTypeRemoteDataSource dataSource;

  PackageTypeRepositoryImpl(this.dataSource);

  @override
  Future<List<PackageTypeEntity>> getPackageTypes() async {
    final models = await dataSource.getPackageTypes();
    return models.map((model) => model.toEntity()).toList();
  }
}
