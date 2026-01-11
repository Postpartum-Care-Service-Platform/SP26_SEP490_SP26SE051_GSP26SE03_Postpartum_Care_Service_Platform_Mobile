import '../../domain/entities/package_entity.dart';
import '../../domain/repositories/package_repository.dart';
import '../datatsources/package_datasource.dart';

/// Package repository implementation - Data layer
class PackageRepositoryImpl implements PackageRepository {
  final PackageDataSource dataSource;

  PackageRepositoryImpl(this.dataSource);

  @override
  Future<List<PackageEntity>> getPackages() async {
    final models = await dataSource.getPackages();
    return models.map((model) => model.toEntity()).toList();
  }
}
