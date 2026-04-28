import 'package:dio/dio.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../../domain/entities/activity_restriction_entity.dart';
import '../../domain/repositories/activity_restriction_repository.dart';
import '../models/activity_restriction_model.dart';

class ActivityRestrictionRepositoryImpl implements ActivityRestrictionRepository {
  final Dio dio;

  ActivityRestrictionRepositoryImpl({required this.dio});

  dynamic _extractData(Response response) {
    if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
      return response.data['data'];
    }
    return response.data;
  }

  @override
  Future<ActivityRestrictionEntity> checkRestriction(int familyProfileId, int activityId) async {
    try {
      final response = await dio.post(
        ApiEndpoints.checkActivityRestriction(activityId),
        data: {'familyProfileId': familyProfileId},
      );
      final model = ActivityRestrictionModel.fromJson(_extractData(response) as Map<String, dynamic>);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to check activity restriction: $e');
    }
  }

  @override
  Future<BatchActivityRestrictionEntity> batchCheckRestrictions(int familyProfileId, List<int> activityIds) async {
    try {
      final response = await dio.post(
        ApiEndpoints.batchCheckRestrictions,
        data: {
          'familyProfileId': familyProfileId,
          'activityIds': activityIds,
        },
      );
      final model = BatchActivityRestrictionModel.fromJson(_extractData(response) as Map<String, dynamic>);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to batch check activity restrictions: $e');
    }
  }
}
