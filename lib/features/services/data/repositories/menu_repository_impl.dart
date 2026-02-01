import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_type_entity.dart';
import '../../domain/entities/menu_record_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_datasource.dart';

/// Menu Repository Implementation - Data layer
class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource dataSource;

  MenuRepositoryImpl(this.dataSource);

  @override
  Future<List<MenuEntity>> getMenus() async {
    final models = await dataSource.getMenus();
    return models;
  }

  @override
  Future<List<MenuTypeEntity>> getMenuTypes() async {
    final models = await dataSource.getMenuTypes();
    return models;
  }

  @override
  Future<List<MenuRecordEntity>> getMyMenuRecords() async {
    final models = await dataSource.getMyMenuRecords();
    return models;
  }

  @override
  Future<List<MenuRecordEntity>> getMyMenuRecordsByDate(DateTime date) async {
    final models = await dataSource.getMyMenuRecordsByDate(date);
    return models;
  }

  @override
  Future<List<MenuRecordEntity>> createMenuRecords(
    List<Map<String, dynamic>> requests,
  ) async {
    final models = await dataSource.createMenuRecords(requests);
    return models;
  }

  @override
  Future<List<MenuRecordEntity>> updateMenuRecords(
    List<Map<String, dynamic>> requests,
  ) async {
    final models = await dataSource.updateMenuRecords(requests);
    return models;
  }

  @override
  Future<MenuRecordEntity> deleteMenuRecord(int id) async {
    final model = await dataSource.deleteMenuRecord(id);
    return model;
  }
}
