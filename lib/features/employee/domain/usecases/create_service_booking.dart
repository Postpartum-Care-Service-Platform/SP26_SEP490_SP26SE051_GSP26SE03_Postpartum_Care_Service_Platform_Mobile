import '../entities/amenity_ticket_entity.dart';
import '../repositories/amenity_ticket_repository.dart';

/// Use case to create service booking
class CreateServiceBooking {
  final AmenityTicketRepository repository;

  CreateServiceBooking(this.repository);

  /// Execute the use case
  /// [customerId] - Customer's user ID
  /// [serviceIds] - List of amenity service IDs
  /// [startTime] - Booking start time
  /// [endTime] - Booking end time
  /// [notes] - Optional notes
  /// Returns list of created tickets
  Future<List<AmenityTicketEntity>> call({
    required String customerId,
    required List<int> serviceIds,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    return await repository.createBooking(
      customerId: customerId,
      serviceIds: serviceIds,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
    );
  }
}
