import '../../data/models/member_type_model.dart';
import '../repositories/family_profile_repository.dart';

/// Use case: get member types for family profiles
class GetMemberTypesUsecase {
  final FamilyProfileRepository repository;

  const GetMemberTypesUsecase(this.repository);

  Future<List<MemberTypeModel>> call() {
    return repository.getMemberTypes();
  }
}

