/// Appointment Status Enum
/// Maps to Backend AppointmentStatus enum
enum AppointmentStatus {
  /// Pending - Chờ xử lý
  pending,
  
  /// Scheduled - Đã lên lịch
  scheduled,
  
  /// Rescheduled - Đã đổi lịch
  rescheduled,
  
  /// Cancelled - Đã hủy
  cancelled,
  
  /// Completed - Đã hoàn thành
  completed,
}

/// Extension for AppointmentStatus
extension AppointmentStatusExtension on AppointmentStatus {
  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
    }
  }

  /// Get display text in Vietnamese
  String get displayText {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Chờ xử lý';
      case AppointmentStatus.scheduled:
        return 'Đã lên lịch';
      case AppointmentStatus.rescheduled:
        return 'Đã đổi lịch';
      case AppointmentStatus.cancelled:
        return 'Đã hủy';
      case AppointmentStatus.completed:
        return 'Hoàn thành';
    }
  }

  /// Parse from API string
  static AppointmentStatus fromApiString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'scheduled':
        return AppointmentStatus.scheduled;
      case 'rescheduled':
        return AppointmentStatus.rescheduled;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'completed':
        return AppointmentStatus.completed;
      default:
        return AppointmentStatus.pending;
    }
  }
}
