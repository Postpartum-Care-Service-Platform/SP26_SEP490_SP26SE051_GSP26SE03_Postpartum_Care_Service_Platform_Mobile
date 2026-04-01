import '../../domain/entities/amenity_ticket_entity.dart';

/// Amenity Ticket Model - Data layer
class AmenityTicketModel extends AmenityTicketEntity {
  const AmenityTicketModel({
    required super.id,
    required super.amenityServiceId,
    super.amenityServiceName,
    required super.customerId,
    required super.startTime,
    required super.endTime,
    required super.status,
  });

  /// Create from JSON
  factory AmenityTicketModel.fromJson(Map<String, dynamic> json) {
  final dateStr = json['date'] as String; // "2026-03-30"
  final startTimeStr = json['startTime'] as String; // "13:00:00"
  final endTimeStr = json['endTime'] as String; // "13:30:00"

  // Gộp date và time để tạo DateTime object
  final startTime = DateTime.parse('${dateStr}T$startTimeStr');
  final endTime = DateTime.parse('${dateStr}T$endTimeStr');

  return AmenityTicketModel(
    id: json['id'] as int,
    amenityServiceId: json['amenityServiceId'] as int,
    amenityServiceName: json['amenityServiceName'] as String?,
    customerId: json['customerId'] as String,
    startTime: startTime,
    endTime: endTime,
    status: json['status'] as String,
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'amenityServiceId': amenityServiceId,
    'amenityServiceName': amenityServiceName,
    'customerId': customerId,
    'date': "${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}",
    'startTime': "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00",
    'endTime': "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00",
    'status': status,
  };
}

  /// Convert to Entity
  AmenityTicketEntity toEntity() {
    return AmenityTicketEntity(
      id: id,
      amenityServiceId: amenityServiceId,
      amenityServiceName: amenityServiceName,
      customerId: customerId,
      startTime: startTime,
      endTime: endTime,
      status: status,
    );
  }
}
