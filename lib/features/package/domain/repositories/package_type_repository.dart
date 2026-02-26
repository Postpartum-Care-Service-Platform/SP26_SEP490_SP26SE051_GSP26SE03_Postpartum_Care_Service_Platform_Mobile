import '../entities/package_type_entity.dart';

/// Package Type repository interface - Domain layer
abstract class PackageTypeRepository {
  /// Get all package types
  Future<List<PackageTypeEntity>> getPackageTypes();
}
