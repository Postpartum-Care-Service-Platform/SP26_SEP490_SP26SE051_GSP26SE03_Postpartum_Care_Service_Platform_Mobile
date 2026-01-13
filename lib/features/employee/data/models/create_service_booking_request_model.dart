/// Request model for creating service booking
class CreateServiceBookingRequestModel {
  final String customerId;
  final List<int> serviceIds;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;

  CreateServiceBookingRequestModel({
    required this.customerId,
    required this.serviceIds,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'serviceIds': serviceIds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'notes': notes,
    };
  }
}
