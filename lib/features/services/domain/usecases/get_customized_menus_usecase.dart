import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetCustomizedMenusUseCase {
  final MenuRepository repository;

  GetCustomizedMenusUseCase(this.repository);

  Future<List<MenuEntity>> call() async {
    return await repository.getCustomizedMenus();
  }
}
