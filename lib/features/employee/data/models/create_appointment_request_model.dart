/// Request model for creating appointment for customer
class CreateAppointmentForCustomerRequestModel {
  final String customerId;
  final DateTime appointmentDate;
  final String? name;

  CreateAppointmentForCustomerRequestModel({
    required this.customerId,
    required this.appointmentDate,
    this.name,
  });

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'date': _formatDateOnly(appointmentDate),
      'time': _formatTimeOnly(appointmentDate),
      'name': name,
    };
  }

  /// Format date as DateOnly (YYYY-MM-DD)
  String _formatDateOnly(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// Format time as TimeOnly (HH:mm:ss)
  String _formatTimeOnly(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:00';
  }
}
