import '../entities/menu_record_entity.dart';
import '../repositories/menu_repository.dart';

/// Get My Menu Records By Date Use Case
class GetMyMenuRecordsByDateUsecase {
  final MenuRepository repository;

  GetMyMenuRecordsByDateUsecase(this.repository);

  Future<List<MenuRecordEntity>> call(DateTime date) async {
    return await repository.getMyMenuRecordsByDate(date);
  }
}
