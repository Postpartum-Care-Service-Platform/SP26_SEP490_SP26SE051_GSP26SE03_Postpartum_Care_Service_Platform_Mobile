import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class CreateCustomizedMenuUseCase {
  final MenuRepository repository;

  CreateCustomizedMenuUseCase(this.repository);

  Future<MenuEntity> call(Map<String, dynamic> request) async {
    return await repository.createCustomizedMenu(request);
  }
}
