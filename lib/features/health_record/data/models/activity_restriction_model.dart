import '../../domain/entities/activity_restriction_entity.dart';

class ActivityRestrictionModel {
  final bool isRestricted;
  final String? reason;
  final List<String> restrictedConditions;

  ActivityRestrictionModel({
    required this.isRestricted,
    this.reason,
    required this.restrictedConditions,
  });

  factory ActivityRestrictionModel.fromJson(Map<String, dynamic> json) {
    return ActivityRestrictionModel(
      isRestricted: json['isRestricted'] as bool? ?? false,
      reason: json['reason'] as String?,
      restrictedConditions: (json['restrictedConditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  ActivityRestrictionEntity toEntity() {
    return ActivityRestrictionEntity(
      isRestricted: isRestricted,
      reason: reason,
      restrictedConditions: restrictedConditions,
    );
  }
}

class BatchActivityRestrictionModel {
  final Map<int, ActivityRestrictionModel> restrictions;

  BatchActivityRestrictionModel({
    required this.restrictions,
  });

  factory BatchActivityRestrictionModel.fromJson(Map<String, dynamic> json) {
    final Map<int, ActivityRestrictionModel> map = {};
    json.forEach((key, value) {
      final id = int.tryParse(key);
      if (id != null) {
        map[id] = ActivityRestrictionModel.fromJson(value as Map<String, dynamic>);
      }
    });
    return BatchActivityRestrictionModel(restrictions: map);
  }

  BatchActivityRestrictionEntity toEntity() {
    return BatchActivityRestrictionEntity(
      restrictions: restrictions.map((key, value) => MapEntry(key, value.toEntity())),
    );
  }
}
