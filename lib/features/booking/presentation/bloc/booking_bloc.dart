import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/create_booking_for_customer_usecase.dart';
import '../../domain/usecases/get_booking_by_id_usecase.dart';
import '../../domain/usecases/get_bookings_usecase.dart';
import '../../domain/usecases/create_payment_link_usecase.dart';
import '../../domain/usecases/check_payment_status_usecase.dart';
import '../../domain/usecases/create_offline_payment_usecase.dart';
import '../../../package/domain/usecases/get_packages_usecase.dart';
import '../../../package/domain/entities/package_entity.dart';
import '../../../employee/domain/usecases/get_available_rooms_by_date_range.dart';
import '../../../employee/domain/entities/room_entity.dart';
import 'booking_event.dart';
import 'booking_state.dart';

/// Booking BloC
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUsecase createBookingUsecase;
  final CancelBookingUsecase cancelBookingUsecase;
  final CreateBookingForCustomerUsecase createBookingForCustomerUsecase;
  final GetBookingByIdUsecase getBookingByIdUsecase;
  final GetBookingsUsecase getBookingsUsecase;
  final CreatePaymentLinkUsecase createPaymentLinkUsecase;
  final CheckPaymentStatusUsecase checkPaymentStatusUsecase;
  final GetPackagesUsecase getPackagesUsecase;
  final GetAvailableRoomsByDateRange getAvailableRoomsByDateRange;
  final GetAllRooms getAllRooms;
  final CreateOfflinePaymentUsecase createOfflinePaymentUsecase;

  // Current selection state
  int? _selectedPackageId;
  int? _selectedRoomId;
  DateTime? _selectedDate;
  List<PackageEntity>? _packages;
  List<RoomEntity>? _rooms;

  // Read-only accessors for UI to restore selections when navigating between steps
  DateTime? get selectedDate => _selectedDate;
  PackageEntity? get selectedPackage {
    if (_selectedPackageId == null || _packages == null) return null;
    try {
      return _packages!.firstWhere((p) => p.id == _selectedPackageId);
    } catch (_) {
      return null;
    }
  }

  List<RoomEntity>? get rooms => _rooms;

  BookingBloc({
    required this.createBookingUsecase,
    required this.cancelBookingUsecase,
    required this.createBookingForCustomerUsecase,
    required this.getBookingByIdUsecase,
    required this.getBookingsUsecase,
    required this.createPaymentLinkUsecase,
    required this.checkPaymentStatusUsecase,
    required this.getPackagesUsecase,
    required this.getAvailableRoomsByDateRange,
    required this.getAllRooms,
    required this.createOfflinePaymentUsecase,
  }) : super(const BookingInitial()) {
    on<BookingLoadPackages>(_onLoadPackages);
    on<BookingSelectPackage>(_onSelectPackage);
    on<BookingLoadRooms>(_onLoadRooms);
    on<BookingSelectRoom>(_onSelectRoom);
    on<BookingSelectDate>(_onSelectDate);
    on<BookingCreateBooking>(_onCreateBooking);
    on<BookingCreateBookingForCustomer>(_onCreateBookingForCustomer);
    on<BookingCreatePaymentLink>(_onCreatePaymentLink);
    on<BookingCreateOfflinePayment>(_onCreateOfflinePayment);
    on<BookingCheckPaymentStatus>(_onCheckPaymentStatus);
    on<BookingLoadById>(_onLoadById);
    on<BookingLoadAll>(_onLoadAll);
    on<BookingCancelRequested>(_onCancelBooking);
    on<BookingReset>(_onReset);
  }

  Future<void> _onLoadPackages(
    BookingLoadPackages event,
    Emitter<BookingState> emit,
  ) async {
    // Prevent duplicate API calls if already loading or loaded
    if (state is BookingLoading || state is BookingPackagesLoaded) {
      return;
    }

    emit(const BookingLoading());
    try {
      final packages = await getPackagesUsecase();
      _packages = packages;
      emit(
        BookingPackagesLoaded(
          packages: packages,
          selectedPackageId: _selectedPackageId,
        ),
      );
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onSelectPackage(
    BookingSelectPackage event,
    Emitter<BookingState> emit,
  ) async {
    _selectedPackageId = event.packageId;
    final currentState = state;
    if (currentState is BookingPackagesLoaded) {
      emit(
        BookingPackagesLoaded(
          packages: currentState.packages,
          selectedPackageId: _selectedPackageId,
        ),
      );
    }

    // If all selections are made, create summary state
    if (_selectedPackageId != null &&
        _selectedRoomId != null &&
        _selectedDate != null) {
      try {
        final package = _packages?.firstWhere(
          (p) => p.id == _selectedPackageId,
        );
        final room = _rooms?.firstWhere((r) => r.id == _selectedRoomId);

        if (package != null && room != null) {
          emit(
            BookingSummaryReady(
              packageId: _selectedPackageId!,
              roomId: _selectedRoomId!,
              startDate: _selectedDate!,
              package: package,
              room: room,
            ),
          );
        }
      } catch (e) {
        // Package or room not found, ignore
      }
    }
  }

  Future<void> _onLoadRooms(
    BookingLoadRooms event,
    Emitter<BookingState> emit,
  ) async {
    // Require package and date to be selected before loading available rooms
    if (_selectedPackageId == null || _selectedDate == null) {
      emit(const BookingError('Vui lòng chọn gói và ngày trước khi chọn phòng'));
      return;
    }

    // Find selected package to get duration
    final package = _packages?.firstWhere(
      (p) => p.id == _selectedPackageId,
      orElse: () => throw Exception('Không tìm thấy gói đã chọn'),
    );

    final durationDays = package?.durationDays;
    if (durationDays == null) {
      emit(const BookingError('Gói chưa có thời lượng ngày hợp lệ'));
      return;
    }

    final startDate = _selectedDate!;
    final endDate = startDate.add(Duration(days: durationDays));

    emit(const BookingLoading());
    try {
      final rooms = await getAvailableRoomsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      _rooms = rooms;
      emit(BookingRoomsLoaded(
        rooms: rooms,
        selectedRoomId: _selectedRoomId,
      ));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onSelectRoom(
    BookingSelectRoom event,
    Emitter<BookingState> emit,
  ) async {
    _selectedRoomId = event.roomId;
    final currentState = state;
    if (currentState is BookingRoomsLoaded) {
      emit(
        BookingRoomsLoaded(
          rooms: currentState.rooms,
          selectedRoomId: _selectedRoomId,
        ),
      );
    }

    // If all selections are made, create summary state
    if (_selectedPackageId != null &&
        _selectedRoomId != null &&
        _selectedDate != null) {
      try {
        final package = _packages?.firstWhere(
          (p) => p.id == _selectedPackageId,
        );
        final room = _rooms?.firstWhere((r) => r.id == _selectedRoomId);

        if (package != null && room != null) {
          emit(
            BookingSummaryReady(
              packageId: _selectedPackageId!,
              roomId: _selectedRoomId!,
              startDate: _selectedDate!,
              package: package,
              room: room,
            ),
          );
        }
      } catch (e) {
        // Package or room not found, ignore
      }
    }
  }

  Future<void> _onSelectDate(
    BookingSelectDate event,
    Emitter<BookingState> emit,
  ) async {
    _selectedDate = event.date;
    PackageEntity? package;
    if (_selectedPackageId != null && _packages != null) {
      try {
        package = _packages!.firstWhere((p) => p.id == _selectedPackageId);
      } catch (_) {
        package = null;
      }
    }
    emit(BookingDateSelected(event.date, package: package));
    
    // If all selections are made, create summary state
    if (_selectedPackageId != null &&
        _selectedRoomId != null &&
        _selectedDate != null) {
      try {
        final package = _packages?.firstWhere(
          (p) => p.id == _selectedPackageId,
        );
        final room = _rooms?.firstWhere((r) => r.id == _selectedRoomId);

        if (package != null && room != null) {
          emit(
            BookingSummaryReady(
              packageId: _selectedPackageId!,
              roomId: _selectedRoomId!,
              startDate: _selectedDate!,
              package: package,
              room: room,
            ),
          );
        }
      } catch (e) {
        // Package or room not found, ignore
      }
    }
  }

  Future<void> _onCreateBooking(
    BookingCreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    if (_selectedPackageId == null ||
        _selectedRoomId == null ||
        _selectedDate == null) {
      emit(const BookingError('Vui lòng chọn đầy đủ thông tin'));
      return;
    }

    emit(const BookingLoading());
    try {
      final booking = await createBookingUsecase(
        packageId: _selectedPackageId!,
        roomId: _selectedRoomId!,
        startDate: _selectedDate!,
      );
      emit(BookingCreated(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCreateBookingForCustomer(
    BookingCreateBookingForCustomer event,
    Emitter<BookingState> emit,
  ) async {
    if (_selectedPackageId == null ||
        _selectedRoomId == null ||
        _selectedDate == null) {
      emit(const BookingError('Vui lòng chọn đầy đủ thông tin'));
      return;
    }

    emit(const BookingLoading());
    try {
      final booking = await createBookingForCustomerUsecase(
        customerId: event.customerId,
        packageId: _selectedPackageId!,
        roomId: _selectedRoomId!,
        startDate: _selectedDate!,
        discountAmount: event.discountAmount,
      );
      emit(BookingCreated(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCreatePaymentLink(
    BookingCreatePaymentLink event,
    Emitter<BookingState> emit,
  ) async {
    final currentState = state;
    int? bookingId = event.bookingId;

    if (bookingId == null) {
      // Support both BookingCreated and BookingLoaded states
      if (currentState is BookingCreated) {
        bookingId = currentState.booking.id;
      } else if (currentState is BookingLoaded) {
        bookingId = currentState.booking.id;
      } else {
        emit(const BookingError('Vui lòng tạo booking trước'));
        return;
      }
    }

    emit(const BookingLoading());
    try {
      final paymentLink = await createPaymentLinkUsecase(
        bookingId: bookingId,
        type: event.type,
        isHomeService: event.isHomeService,
        staffId: event.staffId,
      );
      emit(BookingPaymentLinkCreated(paymentLink));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCreateOfflinePayment(
    BookingCreateOfflinePayment event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final status = await createOfflinePaymentUsecase(
        bookingId: event.bookingId,
        customerId: event.customerId,
        amount: event.amount,
        paymentMethod: event.paymentMethod,
        note: event.note,
      );
      emit(BookingPaymentStatusChecked(status));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCheckPaymentStatus(
    BookingCheckPaymentStatus event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final paymentStatus = await checkPaymentStatusUsecase(event.orderCode);
      emit(BookingPaymentStatusChecked(paymentStatus));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onLoadById(
    BookingLoadById event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final booking = await getBookingByIdUsecase(event.id);
      emit(BookingLoaded(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
    BookingLoadAll event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final bookings = await getBookingsUsecase();
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCancelBooking(
    BookingCancelRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final message = await cancelBookingUsecase(event.id);
      emit(BookingCancelled(bookingId: event.id, message: message));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onReset(
    BookingReset event,
    Emitter<BookingState> emit,
  ) async {
    _selectedPackageId = null;
    _selectedRoomId = null;
    _selectedDate = null;
    _packages = null;
    _rooms = null;
    emit(const BookingInitial());
  }
}
