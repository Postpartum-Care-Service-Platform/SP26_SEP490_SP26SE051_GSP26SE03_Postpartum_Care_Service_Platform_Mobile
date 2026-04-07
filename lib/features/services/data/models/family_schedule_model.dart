import '../../domain/entities/family_schedule_entity.dart';
import 'staff_schedule_model.dart';

/// Family Schedule Model - Data layer
class FamilyScheduleModel extends FamilyScheduleEntity {
  const FamilyScheduleModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    super.customerAvatar,
    required super.packageId,
    required super.packageName,
    super.roomId,
    super.roomName,
    required super.workDate,
    required super.startTime,
    required super.endTime,
    required super.dayNo,
    required super.activity,
    super.title,
    super.description,
    required super.target,
    required super.status,
    super.note,
    super.contractId,
    super.amenityTicketId,
    super.amenityServiceId,
    super.amenityServiceName,
    super.staffSchedules = const [],
  });

  factory FamilyScheduleModel.fromJson(Map<String, dynamic> json) {
    final staffSchedulesJson = json['staffSchedules'] as List<dynamic>? ?? [];
    final staffSchedules = staffSchedulesJson
        .map((item) => StaffScheduleModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return FamilyScheduleModel(
      id: json['id'] as int? ?? 0,
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String?,
      customerAvatar: json['customerAvatar'] as String?,
      packageId: json['packageId'] as int? ?? 0,
      packageName: json['packageName'] as String?,
      roomId: json['roomId'] as int?,
      roomName: json['roomName'] as String?,
      workDate: _parseDateOnly(json['workDate'] as String? ?? DateTime.now().toIso8601String()),
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      dayNo: json['dayNo'] as int? ?? 0,
      activity: json['activity'] as String? ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      target: json['target'] as String? ?? '',
      status: json['status'] as String? ?? '',
      note: json['note'] as String?,
      contractId: json['contractId'] as int?,
      amenityTicketId: json['amenityTicketId'] as int?,
      amenityServiceId: json['amenityServiceId'] as int?,
      amenityServiceName: json['amenityServiceName'] as String?,
      staffSchedules: staffSchedules,
    );
  }

  static DateTime _parseDateOnly(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      return DateTime.parse(value);
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return DateTime.parse(value);
    }
    return DateTime(year, month, day);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerAvatar': customerAvatar,
      'packageId': packageId,
      'packageName': packageName,
      'roomId': roomId,
      'roomName': roomName,
      'workDate': workDate.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      'dayNo': dayNo,
      'activity': activity,
      'title': title,
      'description': description,
      'target': target,
      'status': status,
      'note': note,
      'contractId': contractId,
      'amenityTicketId': amenityTicketId,
      'amenityServiceId': amenityServiceId,
      'amenityServiceName': amenityServiceName,
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
      customerAvatar: customerAvatar,
      packageId: packageId,
      packageName: packageName,
      roomId: roomId,
      roomName: roomName,
      workDate: workDate,
      startTime: startTime,
      endTime: endTime,
      dayNo: dayNo,
      activity: activity,
      title: title,
      description: description,
      target: target,
      status: status,
      note: note,
      contractId: contractId,
      amenityTicketId: amenityTicketId,
      amenityServiceId: amenityServiceId,
      amenityServiceName: amenityServiceName,
      staffSchedules: staffSchedules,
    );
  }
}
