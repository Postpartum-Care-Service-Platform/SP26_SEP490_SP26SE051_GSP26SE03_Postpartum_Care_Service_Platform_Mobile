/// Request model for staff creating amenity ticket
/// Matches BE StaffCreateAmenityTicketRequest structure
class StaffCreateAmenityTicketRequestModel {
  final int amenityServiceId;
  final String customerId; // Guid as String
  final String date; // "yyyy-MM-dd"
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"

  StaffCreateAmenityTicketRequestModel({
    required this.amenityServiceId,
    required this.customerId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'amenityServiceId': amenityServiceId,
      'customerId': customerId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

/// Request model for updating amenity ticket
/// Matches BE UpdateAmenityTicketRequest structure
class UpdateAmenityTicketRequestModel {
  final int amenityServiceId;
  final DateTime startTime;
  final DateTime endTime;

  UpdateAmenityTicketRequestModel({
    required this.amenityServiceId,
    required this.startTime,
    required this.endTime,
  });

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'amenityServiceId': amenityServiceId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }
}
