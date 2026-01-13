import '../../domain/entities/amenity_ticket_entity.dart';
import '../../domain/entities/amenity_ticket_status.dart';
import 'amenity_service_model.dart';

/// AmenityTicket Data Model
/// Maps to API response structure
class AmenityTicketModel {
  final int id;
  final int amenityServiceId;
  final String customerId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final AmenityServiceModel? amenityService;
  final String? customerName;

  AmenityTicketModel({
    required this.id,
    required this.amenityServiceId,
    required this.customerId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.amenityService,
    this.customerName,
  });

  /// Convert from JSON
  factory AmenityTicketModel.fromJson(Map<String, dynamic> json) {
    return AmenityTicketModel(
      id: json['id'] as int,
      amenityServiceId: json['amenityServiceId'] as int,
      customerId: json['customerId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: json['status'] as String,
      amenityService: json['amenityService'] != null
          ? AmenityServiceModel.fromJson(json['amenityService'] as Map<String, dynamic>)
          : null,
      customerName: json['customerName'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amenityServiceId': amenityServiceId,
      'customerId': customerId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'amenityService': amenityService?.toJson(),
      'customerName': customerName,
    };
  }

  /// Convert to Entity
  AmenityTicketEntity toEntity() {
    return AmenityTicketEntity(
      id: id,
      amenityServiceId: amenityServiceId,
      customerId: customerId,
      startTime: startTime,
      endTime: endTime,
      status: AmenityTicketStatusExtension.fromApiString(status),
      amenityService: amenityService?.toEntity(),
      customerName: customerName,
    );
  }

  /// Create from Entity
  factory AmenityTicketModel.fromEntity(AmenityTicketEntity entity) {
    return AmenityTicketModel(
      id: entity.id,
      amenityServiceId: entity.amenityServiceId,
      customerId: entity.customerId,
      startTime: entity.startTime,
      endTime: entity.endTime,
      status: entity.status.toApiString(),
      amenityService: entity.amenityService != null
          ? AmenityServiceModel.fromEntity(entity.amenityService!)
          : null,
      customerName: entity.customerName,
    );
  }
}
