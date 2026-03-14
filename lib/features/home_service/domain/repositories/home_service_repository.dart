import '../entities/home_activity_entity.dart';
import '../entities/home_staff_entity.dart';
import '../entities/home_service_booking_entity.dart';
import '../entities/home_service_selection_entity.dart';
import '../../data/datasources/home_service_remote_datasource.dart';
import '../../../booking/domain/entities/payment_link_entity.dart';
import '../../../booking/domain/entities/payment_status_entity.dart';

/// Home Service Repository Interface
abstract class HomeServiceRepository {
  /// Get all home activities
  Future<List<HomeActivityEntity>> getHomeActivities();

  /// Get free home staff for date list
  Future<List<HomeStaffEntity>> getFreeHomeStaffInDateList(
    List<StaffAvailabilityRequest> requests,
  );

  /// Book home service
  Future<HomeServiceBookingEntity> bookHomeService({
    required String staffId,
    required List<HomeServiceSelectionEntity> selections,
  });

  /// Create payment link for home service
  Future<PaymentLinkEntity> createHomeServicePaymentLink({
    required int bookingId,
    required String type,
    required String staffId,
  });

  /// Check payment status
  Future<PaymentStatusEntity> checkPaymentStatus(String orderCode);
}
