import '../../domain/entities/amenity_ticket_entity.dart';
import '../../../../core/utils/app_date_time_utils.dart';

/// Amenity Ticket Model - Data layer
class AmenityTicketModel extends AmenityTicketEntity {
  const AmenityTicketModel({
    required super.id,
    required super.amenityServiceId,
    required super.customerId,
    required super.startTime,
    required super.endTime,
    required super.status,
  });

  /// Create from JSON
  factory AmenityTicketModel.fromJson(Map<String, dynamic> json) {
    final startTimeStr = json['startTime'] as String;
    final endTimeStr = json['endTime'] as String;

    final startTime = AppDateTimeUtils.parseToVietnamTime(startTimeStr) ??
        DateTime.parse(startTimeStr);
    final endTime = AppDateTimeUtils.parseToVietnamTime(endTimeStr) ??
        DateTime.parse(endTimeStr);

    return AmenityTicketModel(
      id: json['id'] as int,
      amenityServiceId: json['amenityServiceId'] as int,
      customerId: json['customerId'] as String,
      startTime: startTime,
      endTime: endTime,
      status: json['status'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amenityServiceId': amenityServiceId,
      'customerId': customerId,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'status': status,
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
      status: status,
    );
  }
}
