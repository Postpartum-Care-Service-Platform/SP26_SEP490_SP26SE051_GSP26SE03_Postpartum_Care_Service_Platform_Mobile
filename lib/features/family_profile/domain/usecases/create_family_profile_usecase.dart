import '../entities/family_profile_entity.dart';
import '../repositories/family_profile_repository.dart';
import '../../data/models/create_family_profile_request_model.dart';

/// Use case for creating a family profile
class CreateFamilyProfileUsecase {
  final FamilyProfileRepository repository;

  CreateFamilyProfileUsecase(this.repository);

  Future<FamilyProfileEntity> call(CreateFamilyProfileRequestModel request) {
    return repository.createFamilyProfile(request);
  }
}
