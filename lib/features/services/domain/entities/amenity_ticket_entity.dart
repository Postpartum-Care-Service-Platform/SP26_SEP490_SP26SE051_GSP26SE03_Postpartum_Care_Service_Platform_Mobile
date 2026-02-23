import 'package:equatable/equatable.dart';

/// Amenity Ticket Entity - Domain layer
class AmenityTicketEntity extends Equatable {
  final int id;
  final int amenityServiceId;
  final String customerId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // "Booked", "Accepted", "Completed", "Cancelled"

  const AmenityTicketEntity({
    required this.id,
    required this.amenityServiceId,
    required this.customerId,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  /// Check if ticket is booked
  bool get isBooked => status.toLowerCase() == 'booked';

  /// Check if ticket is accepted
  bool get isAccepted => status.toLowerCase() == 'accepted';

  /// Check if ticket is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Check if ticket is cancelled
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  /// Get formatted time range (e.g., "18:00 - 18:30")
  String get timeRange {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  @override
  List<Object?> get props => [
        id,
        amenityServiceId,
        customerId,
        startTime,
        endTime,
        status,
      ];
}
