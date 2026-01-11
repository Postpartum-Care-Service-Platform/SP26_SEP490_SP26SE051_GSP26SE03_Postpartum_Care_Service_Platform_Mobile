import '../entities/package_entity.dart';

/// Package repository interface - Domain layer
abstract class PackageRepository {
  /// Get all packages
  Future<List<PackageEntity>> getPackages();
}
