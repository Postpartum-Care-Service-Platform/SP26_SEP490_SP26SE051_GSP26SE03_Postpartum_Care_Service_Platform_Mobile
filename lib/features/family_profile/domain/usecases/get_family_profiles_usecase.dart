import '../entities/family_profile_entity.dart';
import '../repositories/family_profile_repository.dart';

/// Use case: get current user's family profiles
class GetFamilyProfilesUsecase {
  final FamilyProfileRepository repository;

  const GetFamilyProfilesUsecase(this.repository);

  Future<List<FamilyProfileEntity>> call() {
    return repository.getMyFamilyProfiles();
  }
}

