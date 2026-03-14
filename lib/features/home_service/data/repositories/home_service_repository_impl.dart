import '../../domain/entities/home_activity_entity.dart';
import '../../domain/entities/home_staff_entity.dart';
import '../../domain/entities/home_service_booking_entity.dart';
import '../../domain/entities/home_service_selection_entity.dart';
import '../../domain/repositories/home_service_repository.dart';
import '../datasources/home_service_remote_datasource.dart';
import '../../../booking/domain/entities/payment_link_entity.dart';
import '../../../booking/domain/entities/payment_status_entity.dart';

/// Home Service Repository Implementation
class HomeServiceRepositoryImpl implements HomeServiceRepository {
  final HomeServiceRemoteDataSource remoteDataSource;

  HomeServiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HomeActivityEntity>> getHomeActivities() async {
    try {
      final models = await remoteDataSource.getHomeActivities();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<HomeStaffEntity>> getFreeHomeStaffInDateList(
    List<StaffAvailabilityRequest> requests,
  ) async {
    try {
      final models = await remoteDataSource.getFreeHomeStaffInDateList(requests);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<HomeServiceBookingEntity> bookHomeService({
    required String staffId,
    required List<HomeServiceSelectionEntity> selections,
  }) async {
    try {
      final model = await remoteDataSource.bookHomeService(
        staffId: staffId,
        selections: selections,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<PaymentLinkEntity> createHomeServicePaymentLink({
    required int bookingId,
    required String type,
    required String staffId,
  }) async {
    try {
      final model = await remoteDataSource.createHomeServicePaymentLink(
        bookingId: bookingId,
        type: type,
        staffId: staffId,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<PaymentStatusEntity> checkPaymentStatus(String orderCode) async {
    try {
      final model = await remoteDataSource.checkPaymentStatus(orderCode);
      return model.toEntity();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
