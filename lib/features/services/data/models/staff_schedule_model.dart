import '../../domain/entities/staff_schedule_entity.dart';
import '../../../../core/utils/app_date_time_utils.dart';
import 'family_schedule_model.dart';

/// Staff Schedule Model - Data layer
class StaffScheduleModel extends StaffScheduleEntity {
  const StaffScheduleModel({
    required super.id,
    required super.staffId,
    super.staffName,
    super.managerId,
    super.managerName,
    super.familyScheduleId,
    super.familySchedule,
    required super.isChecked,
    super.checkedAt,
    super.staffAvatar,
  });

  factory StaffScheduleModel.fromJson(Map<String, dynamic> json) {
    // Parse UTC time and convert to Vietnam timezone (+7)
    final checkedAt = AppDateTimeUtils.parseToVietnamTime(
      json['checkedAt'] as String?,
    );
    final familyScheduleJson =
        json['familyScheduleResponse'] as Map<String, dynamic>?;

    return StaffScheduleModel(
      id: json['id'] as int? ?? 0,
      staffId: json['staffId'] as String? ?? '',
      staffName: json['staffName'] as String?,
      managerId: json['managerId'] as String?,
      managerName: json['managerName'] as String?,
      staffAvatar: json['staffAvatar'] as String?,
      familyScheduleId: json['familyScheduleId'] as int?,
      familySchedule: familyScheduleJson == null
          ? null
          : FamilyScheduleModel.fromJson(familyScheduleJson),
      isChecked: json['isChecked'] as bool? ?? false,
      checkedAt: checkedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'staffName': staffName,
      'managerId': managerId,
      'managerName': managerName,
      'familyScheduleId': familyScheduleId,
      'familyScheduleResponse':
          familySchedule == null
              ? null
              : (familySchedule as FamilyScheduleModel).toJson(),
      'isChecked': isChecked,
      'checkedAt': checkedAt?.toIso8601String(),
      'staffAvatar': staffAvatar,
    };
  }

  StaffScheduleEntity toEntity() {
    return StaffScheduleEntity(
      id: id,
      staffId: staffId,
      staffName: staffName,
      managerId: managerId,
      managerName: managerName,
      staffAvatar: staffAvatar,
      familyScheduleId: familyScheduleId,
      familySchedule: familySchedule,
      isChecked: isChecked,
      checkedAt: checkedAt,
    );
  }
}
