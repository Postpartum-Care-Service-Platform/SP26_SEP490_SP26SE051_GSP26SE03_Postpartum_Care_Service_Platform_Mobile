import '../entities/menu_record_entity.dart';
import '../repositories/menu_repository.dart';

/// Update Menu Records Use Case
class UpdateMenuRecordsUsecase {
  final MenuRepository repository;

  UpdateMenuRecordsUsecase(this.repository);

  Future<List<MenuRecordEntity>> call(
    List<Map<String, dynamic>> requests,
  ) async {
    return await repository.updateMenuRecords(requests);
  }
}
