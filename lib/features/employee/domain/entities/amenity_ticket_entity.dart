import 'amenity_ticket_status.dart';
import 'amenity_service_entity.dart';

/// Amenity Ticket Entity
/// Domain model for amenity service booking/ticket
class AmenityTicketEntity {
  /// Ticket ID
  final int id;
  
  /// Amenity Service ID
  final int amenityServiceId;
  
  /// Customer ID
  final String customerId;
  
  /// Start time
  final DateTime startTime;
  
  /// End time
  final DateTime endTime;
  
  /// Ticket status
  final AmenityTicketStatus status;
  
  /// Amenity Service info (optional)
  final AmenityServiceEntity? amenityService;
  
  /// Customer name (optional, for display)
  final String? customerName;

  const AmenityTicketEntity({
    required this.id,
    required this.amenityServiceId,
    required this.customerId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.amenityService,
    this.customerName,
  });

  /// Create a copy with updated fields
  AmenityTicketEntity copyWith({
    int? id,
    int? amenityServiceId,
    String? customerId,
    DateTime? startTime,
    DateTime? endTime,
    AmenityTicketStatus? status,
    AmenityServiceEntity? amenityService,
    String? customerName,
  }) {
    return AmenityTicketEntity(
      id: id ?? this.id,
      amenityServiceId: amenityServiceId ?? this.amenityServiceId,
      customerId: customerId ?? this.customerId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      amenityService: amenityService ?? this.amenityService,
      customerName: customerName ?? this.customerName,
    );
  }
}
