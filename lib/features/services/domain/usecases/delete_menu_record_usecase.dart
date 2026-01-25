import '../entities/menu_record_entity.dart';
import '../repositories/menu_repository.dart';

/// Delete Menu Record Use Case
class DeleteMenuRecordUsecase {
  final MenuRepository repository;

  DeleteMenuRecordUsecase(this.repository);

  Future<MenuRecordEntity> call(int id) async {
    return await repository.deleteMenuRecord(id);
  }
}
