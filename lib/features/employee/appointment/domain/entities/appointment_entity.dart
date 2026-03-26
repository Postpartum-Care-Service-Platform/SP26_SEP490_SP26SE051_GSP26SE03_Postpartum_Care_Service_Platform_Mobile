import 'appointment_status.dart';

/// Appointment Entity
/// Domain model for appointment data
class AppointmentEntity {
  /// Appointment ID
  final int id;
  
  /// Customer ID
  final String customerId;
  
  /// Staff ID (nullable)
  final String? staffId;
  
  /// Appointment name/title
  final String? name;
  
  /// Created at timestamp
  final DateTime createdAt;
  
  /// Appointment status
  final AppointmentStatus status;
  
  /// Appointment date and time
  final DateTime appointmentDate;
  
  /// Customer information
  final CustomerInfo? customer;
  
  /// Staff information
  final StaffInfo? staff;

  const AppointmentEntity({
    required this.id,
    required this.customerId,
    this.staffId,
    this.name,
    required this.createdAt,
    required this.status,
    required this.appointmentDate,
    this.customer,
    this.staff,
  });

  /// Create a copy with updated fields
  AppointmentEntity copyWith({
    int? id,
    String? customerId,
    String? staffId,
    String? name,
    DateTime? createdAt,
    AppointmentStatus? status,
    DateTime? appointmentDate,
    CustomerInfo? customer,
    StaffInfo? staff,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      staffId: staffId ?? this.staffId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      customer: customer ?? this.customer,
      staff: staff ?? this.staff,
    );
  }
}

/// Customer Information
class CustomerInfo {
  /// Customer ID
  final String id;
  
  /// Customer email
  final String email;
  
  /// Customer username
  final String? username;
  
  /// Customer phone
  final String? phone;

  const CustomerInfo({
    required this.id,
    required this.email,
    this.username,
    this.phone,
  });
}

/// Staff Information
class StaffInfo {
  /// Staff ID
  final String id;
  
  /// Staff email
  final String email;
  
  /// Staff username
  final String? username;

  const StaffInfo({
    required this.id,
    required this.email,
    this.username,
  });
}
