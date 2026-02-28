import '../../domain/entities/family_profile_entity.dart';
import '../../domain/repositories/family_profile_repository.dart';
import '../datasources/family_profile_remote_datasource.dart';
import '../models/member_type_model.dart';
import '../models/create_family_profile_request_model.dart';
import '../models/update_family_profile_request_model.dart';

/// Family profile repository implementation
class FamilyProfileRepositoryImpl implements FamilyProfileRepository {
  final FamilyProfileRemoteDataSource remoteDataSource;

  FamilyProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FamilyProfileEntity>> getMyFamilyProfiles() async {
    try {
      final models = await remoteDataSource.getMyFamilyProfiles();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FamilyProfileEntity>> getFamilyProfilesByCustomerId(
    String customerId,
  ) async {
    try {
      final models =
          await remoteDataSource.getFamilyProfilesByCustomerId(customerId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MemberTypeModel>> getMemberTypes() async {
    try {
      return await remoteDataSource.getMemberTypes();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FamilyProfileEntity> createFamilyProfile(
    CreateFamilyProfileRequestModel request,
  ) async {
    try {
      final model = await remoteDataSource.createFamilyProfile(request);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FamilyProfileEntity> updateFamilyProfile(
    int id,
    UpdateFamilyProfileRequestModel request,
  ) async {
    try {
      final model = await remoteDataSource.updateFamilyProfile(id, request);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
