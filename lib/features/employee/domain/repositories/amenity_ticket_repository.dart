import '../entities/amenity_ticket_entity.dart';

/// AmenityTicket Repository Interface
/// Defines contract for amenity ticket/booking operations
abstract class AmenityTicketRepository {
  /// Create amenity ticket booking
  /// [customerId] - Customer's user ID
  /// [serviceIds] - List of amenity service IDs to book
  /// [startTime] - Booking start time
  /// [endTime] - Booking end time
  /// [notes] - Optional notes
  /// Returns list of created tickets
  Future<List<AmenityTicketEntity>> createBooking({
    required String customerId,
    required List<int> serviceIds,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });

  /// Get tickets by customer ID
  /// [customerId] - Customer's user ID
  /// Returns list of tickets
  Future<List<AmenityTicketEntity>> getTicketsByCustomer(String customerId);

  /// Get tickets by staff (all tickets assigned to staff)
  /// Returns list of tickets
  Future<List<AmenityTicketEntity>> getMyAssignedTickets();

  /// Get all tickets (for admin/staff)
  /// Returns list of all tickets
  Future<List<AmenityTicketEntity>> getAllTickets();

  /// Cancel ticket
  /// [ticketId] - Ticket ID to cancel
  /// Returns success message
  Future<String> cancelTicket(int ticketId);

  /// Confirm ticket
  /// [ticketId] - Ticket ID to confirm
  /// Returns success message
  Future<String> confirmTicket(int ticketId);

  /// Complete ticket
  /// [ticketId] - Ticket ID to complete
  /// Returns success message
  Future<String> completeTicket(int ticketId);
}
