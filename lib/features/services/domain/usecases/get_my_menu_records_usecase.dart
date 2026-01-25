import '../entities/menu_record_entity.dart';
import '../repositories/menu_repository.dart';

/// Get My Menu Records Use Case
class GetMyMenuRecordsUsecase {
  final MenuRepository repository;

  GetMyMenuRecordsUsecase(this.repository);

  Future<List<MenuRecordEntity>> call() async {
    return await repository.getMyMenuRecords();
  }
}
