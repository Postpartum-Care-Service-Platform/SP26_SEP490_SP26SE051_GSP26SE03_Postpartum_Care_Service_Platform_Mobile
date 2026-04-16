import '../../../auth/data/models/current_account_model.dart';
import '../entities/package_entity.dart';

/// Package repository interface - Domain layer
abstract class PackageRepository {
  /// Get all packages
  Future<List<PackageEntity>> getPackages();
  
  /// Get package by ID
  Future<PackageEntity> getPackageById(int id);

  /// Get now package for current user
  Future<NowPackageModel> getNowPackage();
}
