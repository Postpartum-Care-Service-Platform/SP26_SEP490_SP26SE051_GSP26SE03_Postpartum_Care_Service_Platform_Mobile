import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

/// Get Menus Use Case
class GetMenusUsecase {
  final MenuRepository repository;

  GetMenusUsecase(this.repository);

  Future<List<MenuEntity>> call() async {
    return await repository.getMenus();
  }
}
