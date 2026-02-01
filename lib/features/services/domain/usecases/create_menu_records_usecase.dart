import '../entities/menu_record_entity.dart';
import '../repositories/menu_repository.dart';

/// Create Menu Records Use Case
class CreateMenuRecordsUsecase {
  final MenuRepository repository;

  CreateMenuRecordsUsecase(this.repository);

  Future<List<MenuRecordEntity>> call(
    List<Map<String, dynamic>> requests,
  ) async {
    return await repository.createMenuRecords(requests);
  }
}
