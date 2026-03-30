import '../entities/amenity_ticket_entity.dart';
import '../repositories/amenity_ticket_repository.dart';

/// Use case to create service booking
class CreateServiceBooking {
  final AmenityTicketRepository repository;

  CreateServiceBooking(this.repository);

  /// Execute the use case
  /// [customerId] - Customer's user ID
  /// [amenityServiceId] - Amenity service ID
  /// [date] - Booking date (yyyy-MM-dd)
  /// [startTime] - Booking start time (HH:mm)
  /// [endTime] - Booking end time (HH:mm)
  /// Returns created ticket
  Future<AmenityTicketEntity> call({
    required String customerId,
    required int amenityServiceId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    return await repository.createBooking(
      customerId: customerId,
      amenityServiceId: amenityServiceId,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );
  }
}
