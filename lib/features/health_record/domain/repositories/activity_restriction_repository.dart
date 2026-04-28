import '../entities/activity_restriction_entity.dart';

abstract class ActivityRestrictionRepository {
  Future<ActivityRestrictionEntity> checkRestriction(int familyProfileId, int activityId);
  Future<BatchActivityRestrictionEntity> batchCheckRestrictions(int familyProfileId, List<int> activityIds);
}
