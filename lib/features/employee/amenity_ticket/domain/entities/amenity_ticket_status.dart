/// Amenity Ticket Status Enum
/// Maps to Backend AmenityTicketStatus enum
enum AmenityTicketStatus {
  /// Booked - Đã đặt
  booked,
  
  /// Completed - Đã hoàn thành
  completed,
  
  /// Cancelled - Đã hủy
  cancelled,
}

/// Extension for AmenityTicketStatus
extension AmenityTicketStatusExtension on AmenityTicketStatus {
  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case AmenityTicketStatus.booked:
        return 'Booked';
      case AmenityTicketStatus.completed:
        return 'Completed';
      case AmenityTicketStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get display text in Vietnamese
  String get displayText {
    switch (this) {
      case AmenityTicketStatus.booked:
        return 'Đã đặt';
      case AmenityTicketStatus.completed:
        return 'Đã hoàn thành';
      case AmenityTicketStatus.cancelled:
        return 'Đã hủy';
    }
  }

  /// Parse from API string
  static AmenityTicketStatus fromApiString(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return AmenityTicketStatus.booked;
      case 'completed':
        return AmenityTicketStatus.completed;
      case 'cancelled':
        return AmenityTicketStatus.cancelled;
      default:
        return AmenityTicketStatus.booked;
    }
  }
}
