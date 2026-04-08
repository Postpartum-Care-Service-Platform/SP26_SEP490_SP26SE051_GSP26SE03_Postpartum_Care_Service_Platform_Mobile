import 'package:equatable/equatable.dart';
import 'staff_schedule_entity.dart';

/// Family Schedule Entity - Domain layer
class FamilyScheduleEntity extends Equatable {
  final int id;
  final String customerId;
  final String? customerName;
  final String? customerAvatar;
  final int? packageId;
  final String? packageName;
  final int? roomId;
  final String? roomName;
  final DateTime workDate;
  final String startTime; // Format: "HH:mm:ss"
  final String endTime; // Format: "HH:mm:ss"
  final int dayNo;
  final String activity;
  final String? title;
  final String? description;
  final String target; // "Mom", "Baby", or "Both"
  final String status; // "Scheduled", "Completed", etc.
  final String? note;
  final int? contractId;
  final int? amenityTicketId;
  final int? amenityServiceId;
  final String? amenityServiceName;
  final List<StaffScheduleEntity> staffSchedules; // Can be empty list

  const FamilyScheduleEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerAvatar,
    this.packageId,
    this.packageName,
    this.roomId,
    this.roomName,
    required this.workDate,
    required this.startTime,
    required this.endTime,
    required this.dayNo,
    required this.activity,
    this.title,
    this.description,
    required this.target,
    required this.status,
    this.note,
    this.contractId,
    this.amenityTicketId,
    this.amenityServiceId,
    this.amenityServiceName,
    this.staffSchedules = const [],
  });

  /// Check if activity is completed (Done)
  bool get isCompleted => status.toLowerCase() == 'done';

  /// Check if activity was marked done by staff and waiting customer confirmation
  bool get isStaffDone => status.toLowerCase() == 'staffdone';

  /// Check if activity is missed
  bool get isMissed => status.toLowerCase() == 'missed';

  /// Check if activity is cancelled
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  /// Check if activity is for Mom
  bool get isForMom => target.toLowerCase() == 'mom';

  /// Check if activity is for Baby
  bool get isForBaby => target.toLowerCase() == 'baby';

  /// Check if activity is for Both (Mom and Baby)
  bool get isForBoth => target.toLowerCase() == 'both';

  /// Get formatted time range (e.g., "07:00 - 07:15")
  String get timeRange => '${startTime.substring(0, 5)} - ${endTime.substring(0, 5)}';

  /// Check if has staff assigned
  bool get hasStaff => staffSchedules.isNotEmpty;

  /// Get staff count
  int get staffCount => staffSchedules.length;

  /// Get checked staff count
  int get checkedStaffCount => staffSchedules.where((s) => s.isChecked).length;

  /// Check if all staff are checked
  bool get allStaffChecked => hasStaff && checkedStaffCount == staffCount;

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        customerAvatar,
        packageId,
        packageName,
        roomId,
        roomName,
        workDate,
        startTime,
        endTime,
        dayNo,
        activity,
        title,
        description,
        target,
        status,
        note,
        contractId,
        amenityTicketId,
        amenityServiceId,
        amenityServiceName,
        staffSchedules,
      ];
}
