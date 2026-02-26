import 'package:equatable/equatable.dart';
import '../../domain/entities/care_plan_entity.dart';

/// Care Plan Model - Data layer
class CarePlanModel extends Equatable {
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

  const CarePlanModel({
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

  factory CarePlanModel.fromJson(Map<String, dynamic> json) {
    return CarePlanModel(
      id: json['id'] as int,
      packageId: json['packageId'] as int,
      packageName: json['packageName'] as String,
      activityId: json['activityId'] as int,
      activityName: json['activityName'] as String,
      dayNo: json['dayNo'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      instruction: json['instruction'] as String?,
      sortOrder: json['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageId': packageId,
      'packageName': packageName,
      'activityId': activityId,
      'activityName': activityName,
      'dayNo': dayNo,
      'startTime': startTime,
      'endTime': endTime,
      'instruction': instruction,
      'sortOrder': sortOrder,
    };
  }

  CarePlanEntity toEntity() {
    return CarePlanEntity(
      id: id,
      packageId: packageId,
      packageName: packageName,
      activityId: activityId,
      activityName: activityName,
      dayNo: dayNo,
      startTime: startTime,
      endTime: endTime,
      instruction: instruction,
      sortOrder: sortOrder,
    );
  }

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
