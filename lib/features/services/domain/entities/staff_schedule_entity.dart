import 'package:equatable/equatable.dart';

/// Staff Schedule Entity - Domain layer
class StaffScheduleEntity extends Equatable {
  final int id;
  final String staffId;
  final String? staffName;
  final String managerId;
  final String? managerName;
  final int familyScheduleId;
  final bool isChecked;
  final DateTime? checkedAt;

  const StaffScheduleEntity({
    required this.id,
    required this.staffId,
    this.staffName,
    required this.managerId,
    this.managerName,
    required this.familyScheduleId,
    required this.isChecked,
    this.checkedAt,
  });

  @override
  List<Object?> get props => [
        id,
        staffId,
        staffName,
        managerId,
        managerName,
        familyScheduleId,
        isChecked,
        checkedAt,
      ];
}
