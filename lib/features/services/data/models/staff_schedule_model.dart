import '../../domain/entities/staff_schedule_entity.dart';
import '../../../../core/utils/app_date_time_utils.dart';

/// Staff Schedule Model - Data layer
class StaffScheduleModel extends StaffScheduleEntity {
  const StaffScheduleModel({
    required super.id,
    required super.staffId,
    super.staffName,
    required super.managerId,
    super.managerName,
    required super.familyScheduleId,
    required super.isChecked,
    super.checkedAt,
  });

  factory StaffScheduleModel.fromJson(Map<String, dynamic> json) {
    // Parse UTC time and convert to Vietnam timezone (+7)
    final checkedAt = AppDateTimeUtils.parseToVietnamTime(json['checkedAt'] as String?);

    return StaffScheduleModel(
      id: json['id'] as int,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String?,
      managerId: json['managerId'] as String,
      managerName: json['managerName'] as String?,
      familyScheduleId: json['familyScheduleId'] as int,
      isChecked: json['isChecked'] as bool,
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
      'isChecked': isChecked,
      'checkedAt': checkedAt?.toIso8601String(),
    };
  }

  StaffScheduleEntity toEntity() {
    return StaffScheduleEntity(
      id: id,
      staffId: staffId,
      staffName: staffName,
      managerId: managerId,
      managerName: managerName,
      familyScheduleId: familyScheduleId,
      isChecked: isChecked,
      checkedAt: checkedAt,
    );
  }
}
