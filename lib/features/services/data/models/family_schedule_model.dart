import '../../domain/entities/family_schedule_entity.dart';
import 'staff_schedule_model.dart';

/// Family Schedule Model - Data layer
class FamilyScheduleModel extends FamilyScheduleEntity {
  const FamilyScheduleModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.packageId,
    required super.packageName,
    required super.workDate,
    required super.startTime,
    required super.endTime,
    required super.dayNo,
    required super.activity,
    required super.target,
    required super.status,
    super.note,
    super.contractId,
    super.staffSchedules = const [],
  });

  factory FamilyScheduleModel.fromJson(Map<String, dynamic> json) {
    final staffSchedulesJson = json['staffSchedules'] as List<dynamic>? ?? [];
    final staffSchedules = staffSchedulesJson
        .map((item) => StaffScheduleModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return FamilyScheduleModel(
      id: json['id'] as int,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      packageId: json['packageId'] as int,
      packageName: json['packageName'] as String? ?? '',
      workDate: DateTime.parse(json['workDate'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      dayNo: json['dayNo'] as int,
      activity: json['activity'] as String,
      target: json['target'] as String,
      status: json['status'] as String,
      note: json['note'] as String?,
      contractId: json['contractId'] as int?,
      staffSchedules: staffSchedules,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'packageId': packageId,
      'packageName': packageName,
      'workDate': workDate.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      'dayNo': dayNo,
      'activity': activity,
      'target': target,
      'status': status,
      'note': note,
      'contractId': contractId,
      'staffSchedules': staffSchedules
          .map((item) => (item as StaffScheduleModel).toJson())
          .toList(),
    };
  }

  FamilyScheduleEntity toEntity() {
    return FamilyScheduleEntity(
      id: id,
      customerId: customerId,
      customerName: customerName,
      packageId: packageId,
      packageName: packageName,
      workDate: workDate,
      startTime: startTime,
      endTime: endTime,
      dayNo: dayNo,
      activity: activity,
      target: target,
      status: status,
      note: note,
      contractId: contractId,
      staffSchedules: staffSchedules,
    );
  }
}
