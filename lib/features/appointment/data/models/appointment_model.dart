import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_entity.dart';
import 'user_info_model.dart';
import 'appointment_type_model.dart';

/// Appointment model - Data layer
class AppointmentModel extends Equatable {
  final int id;
  final DateTime appointmentDate;
  final String name;
  final AppointmentStatus status;
  final DateTime createdAt;
  final UserInfoModel? customer;
  final UserInfoModel? staff;
  final AppointmentTypeModel? appointmentType;

  const AppointmentModel({
    required this.id,
    required this.appointmentDate,
    required this.name,
    required this.status,
    required this.createdAt,
    this.customer,
    this.staff,
    this.appointmentType,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle id - can be int or String
      final idValue = json['id'];
      final int id;
      if (idValue is int) {
        id = idValue;
      } else if (idValue is String) {
        id = int.parse(idValue);
      } else {
        throw Exception('Invalid id type: ${idValue.runtimeType}');
      }
      
      // Handle appointmentDate
      final appointmentDateValue = json['appointmentDate'];
      final DateTime appointmentDate;
      if (appointmentDateValue is String) {
        appointmentDate = DateTime.parse(appointmentDateValue);
      } else {
        throw Exception('Invalid appointmentDate type: ${appointmentDateValue.runtimeType}');
      }
      
      // Handle name
      final name = json['name'] as String? ?? '';
      
      // Handle status
      final statusValue = json['status'];
      final AppointmentStatus status;
      if (statusValue is String) {
        status = _parseStatus(statusValue);
      } else {
        status = AppointmentStatus.pending;
      }
      
      // Handle createdAt
      final createdAtValue = json['createdAt'];
      final DateTime createdAt;
      if (createdAtValue is String) {
        createdAt = DateTime.parse(createdAtValue);
      } else {
        createdAt = DateTime.now();
      }
      
      // Handle customer
      final customer = json['customer'] != null
          ? UserInfoModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null;
      
      // Handle staff
      final staff = json['staff'] != null
          ? UserInfoModel.fromJson(json['staff'] as Map<String, dynamic>)
          : null;
      
      // Handle appointmentType (optional)
      final appointmentTypeJson = json['appointmentType'];
      final appointmentType = appointmentTypeJson != null
          ? AppointmentTypeModel.fromJson(
              appointmentTypeJson as Map<String, dynamic>,
            )
          : null;

      final model = AppointmentModel(
        id: id,
        appointmentDate: appointmentDate,
        name: name,
        status: status,
        createdAt: createdAt,
        customer: customer,
        staff: staff,
        appointmentType: appointmentType,
      );
      return model;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentDate': appointmentDate.toIso8601String(),
      'name': name,
      'status': _statusToString(status),
      'createdAt': createdAt.toIso8601String(),
      if (customer != null) 'customer': customer!.toJson(),
      if (staff != null) 'staff': staff!.toJson(),
      if (appointmentType != null) 'appointmentType': appointmentType!.toJson(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
    };
  }

  AppointmentEntity toEntity() {
    return AppointmentEntity(
      id: id,
      appointmentDate: appointmentDate,
      name: name,
      status: status,
      createdAt: createdAt,
      customer: customer?.toEntity(),
      staff: staff?.toEntity(),
      appointmentType: appointmentType?.toEntity(),
    );
  }

  static AppointmentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppointmentStatus.scheduled;
      case 'rescheduled':
        return AppointmentStatus.rescheduled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'pending':
        return AppointmentStatus.pending;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  static String _statusToString(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  List<Object?> get props => [
        id,
        appointmentDate,
        name,
        status,
        createdAt,
        customer,
        staff,
        appointmentType,
      ];
}
