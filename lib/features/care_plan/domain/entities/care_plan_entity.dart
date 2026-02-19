import 'package:equatable/equatable.dart';

/// Care Plan Entity - Domain layer
class CarePlanEntity extends Equatable {
  final int id;
  final int packageId;
  final String packageName;
  final int activityId;
  final String activityName;
  final int dayNo;
  final String startTime;
  final String endTime;
  final String? instruction;
  final int sortOrder;

  const CarePlanEntity({
    required this.id,
    required this.packageId,
    required this.packageName,
    required this.activityId,
    required this.activityName,
    required this.dayNo,
    required this.startTime,
    required this.endTime,
    this.instruction,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [
        id,
        packageId,
        packageName,
        activityId,
        activityName,
        dayNo,
        startTime,
        endTime,
        instruction,
        sortOrder,
      ];
}
