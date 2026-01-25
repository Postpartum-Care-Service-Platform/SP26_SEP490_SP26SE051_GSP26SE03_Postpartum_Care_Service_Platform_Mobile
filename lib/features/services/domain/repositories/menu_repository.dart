import '../entities/menu_entity.dart';
import '../entities/menu_type_entity.dart';
import '../entities/menu_record_entity.dart';

/// Menu Repository Interface - Domain layer
abstract class MenuRepository {
  /// Get all menus
  Future<List<MenuEntity>> getMenus();

  /// Get all menu types
  Future<List<MenuTypeEntity>> getMenuTypes();

  /// Get my menu records (all selected menus)
  Future<List<MenuRecordEntity>> getMyMenuRecords();

  /// Get my menu records by date
  Future<List<MenuRecordEntity>> getMyMenuRecordsByDate(DateTime date);

  /// Create menu records (select menus for dates)
  Future<List<MenuRecordEntity>> createMenuRecords(
    List<Map<String, dynamic>> requests,
  );

  /// Update menu records
  Future<List<MenuRecordEntity>> updateMenuRecords(
    List<Map<String, dynamic>> requests,
  );

  /// Delete menu record (soft delete)
  Future<MenuRecordEntity> deleteMenuRecord(int id);
}
