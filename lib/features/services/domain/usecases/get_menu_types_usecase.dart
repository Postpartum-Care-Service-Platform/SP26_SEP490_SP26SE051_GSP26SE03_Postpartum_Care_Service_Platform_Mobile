import '../entities/menu_type_entity.dart';
import '../repositories/menu_repository.dart';

/// Get Menu Types Use Case
class GetMenuTypesUsecase {
  final MenuRepository repository;

  GetMenuTypesUsecase(this.repository);

  Future<List<MenuTypeEntity>> call() async {
    return await repository.getMenuTypes();
  }
}
