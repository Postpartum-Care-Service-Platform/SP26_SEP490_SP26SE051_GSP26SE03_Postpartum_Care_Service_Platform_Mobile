import '../entities/family_profile_entity.dart';
import '../../data/models/member_type_model.dart';
import '../../data/models/create_family_profile_request_model.dart';
import '../../data/models/update_family_profile_request_model.dart';

/// Family profile repository interface
abstract class FamilyProfileRepository {
  Future<List<FamilyProfileEntity>> getMyFamilyProfiles();
  Future<List<MemberTypeModel>> getMemberTypes();
  Future<FamilyProfileEntity> createFamilyProfile(
    CreateFamilyProfileRequestModel request,
  );
  Future<FamilyProfileEntity> updateFamilyProfile(
    int id,
    UpdateFamilyProfileRequestModel request,
  );
}
