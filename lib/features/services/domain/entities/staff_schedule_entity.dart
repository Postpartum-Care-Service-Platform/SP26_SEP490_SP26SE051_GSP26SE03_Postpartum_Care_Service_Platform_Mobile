import 'package:equatable/equatable.dart';
import 'family_schedule_entity.dart';

/// Staff Schedule Entity - Domain layer
class StaffScheduleEntity extends Equatable {
  final int id;
  final String staffId;
  final String? staffName;
  final String? managerId;
  final String? managerName;
  final String? staffAvatar;
  final int? familyScheduleId;
  final FamilyScheduleEntity? familySchedule;
  final bool isChecked;
  final DateTime? checkedAt;
  final int? roomId;
  final String? roomName;
  final List<String> images;

  const StaffScheduleEntity({
    required this.id,
    required this.staffId,
    this.staffName,
    this.managerId,
    this.managerName,
    this.staffAvatar,
    this.familyScheduleId,
    this.familySchedule,
    required this.isChecked,
    this.checkedAt,
    this.roomId,
    this.roomName,
    this.images = const [],
  });

  @override
  List<Object?> get props => [
        id,
        staffId,
        staffName,
        managerId,
        managerName,
        staffAvatar,
        familyScheduleId,
        familySchedule,
        isChecked,
        checkedAt,
        roomId,
        roomName,
        images,
      ];
}
