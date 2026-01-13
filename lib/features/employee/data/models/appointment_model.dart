import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_status.dart';

/// Appointment Data Model
/// Maps to API response structure
class AppointmentModel {
  final int id;
  final String customerId;
  final String? staffId;
  final String? name;
  final DateTime createdAt;
  final String status;
  final DateTime appointmentDate;
  final CustomerInfoModel? customer;
  final StaffInfoModel? staff;

  AppointmentModel({
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

  /// Convert from JSON
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int,
      customerId: json['customerId'] as String? ?? '',
      staffId: json['staffId'] as String?,
      name: json['name'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      customer: json['customer'] != null
          ? CustomerInfoModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      staff: json['staff'] != null
          ? StaffInfoModel.fromJson(json['staff'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'staffId': staffId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'appointmentDate': appointmentDate.toIso8601String(),
      'customer': customer?.toJson(),
      'staff': staff?.toJson(),
    };
  }

  /// Convert to Entity
  AppointmentEntity toEntity() {
    return AppointmentEntity(
      id: id,
      customerId: customerId,
      staffId: staffId,
      name: name,
      createdAt: createdAt,
      status: AppointmentStatusExtension.fromApiString(status),
      appointmentDate: appointmentDate,
      customer: customer?.toEntity(),
      staff: staff?.toEntity(),
    );
  }

  /// Create from Entity
  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      customerId: entity.customerId,
      staffId: entity.staffId,
      name: entity.name,
      createdAt: entity.createdAt,
      status: entity.status.toApiString(),
      appointmentDate: entity.appointmentDate,
      customer: entity.customer != null
          ? CustomerInfoModel.fromEntity(entity.customer!)
          : null,
      staff: entity.staff != null 
          ? StaffInfoModel.fromEntity(entity.staff!) 
          : null,
    );
  }
}

/// Customer Info Model
class CustomerInfoModel {
  final String id;
  final String email;
  final String? username;
  final String? phone;

  CustomerInfoModel({
    required this.id,
    required this.email,
    this.username,
    this.phone,
  });

  factory CustomerInfoModel.fromJson(Map<String, dynamic> json) {
    return CustomerInfoModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
    };
  }

  CustomerInfo toEntity() {
    return CustomerInfo(
      id: id,
      email: email,
      username: username,
      phone: phone,
    );
  }

  factory CustomerInfoModel.fromEntity(CustomerInfo entity) {
    return CustomerInfoModel(
      id: entity.id,
      email: entity.email,
      username: entity.username,
      phone: entity.phone,
    );
  }
}

/// Staff Info Model
class StaffInfoModel {
  final String id;
  final String email;
  final String? username;

  StaffInfoModel({
    required this.id,
    required this.email,
    this.username,
  });

  factory StaffInfoModel.fromJson(Map<String, dynamic> json) {
    return StaffInfoModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
    };
  }

  StaffInfo toEntity() {
    return StaffInfo(
      id: id,
      email: email,
      username: username,
    );
  }

  factory StaffInfoModel.fromEntity(StaffInfo entity) {
    return StaffInfoModel(
      id: entity.id,
      email: entity.email,
      username: entity.username,
    );
  }
}
