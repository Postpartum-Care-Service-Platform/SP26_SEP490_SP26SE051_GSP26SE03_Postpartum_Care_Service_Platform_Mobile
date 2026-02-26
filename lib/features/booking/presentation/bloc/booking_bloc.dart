import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../domain/usecases/get_booking_by_id_usecase.dart';
import '../../domain/usecases/get_bookings_usecase.dart';
import '../../domain/usecases/create_payment_link_usecase.dart';
import '../../domain/usecases/check_payment_status_usecase.dart';
import '../../../package/domain/usecases/get_packages_usecase.dart';
import '../../../package/domain/entities/package_entity.dart';
import '../../../employee/domain/usecases/get_all_rooms.dart';
import '../../../employee/domain/entities/room_entity.dart';
import '../../../employee/domain/entities/room_status.dart';
import 'booking_event.dart';
import 'booking_state.dart';

/// Booking BloC
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUsecase createBookingUsecase;
  final GetBookingByIdUsecase getBookingByIdUsecase;
  final GetBookingsUsecase getBookingsUsecase;
  final CreatePaymentLinkUsecase createPaymentLinkUsecase;
  final CheckPaymentStatusUsecase checkPaymentStatusUsecase;
  final GetPackagesUsecase getPackagesUsecase;
  final GetAllRooms getAllRooms;

  // Current selection state
  int? _selectedPackageId;
  int? _selectedRoomId;
  DateTime? _selectedDate;
  List<PackageEntity>? _packages;
  List<RoomEntity>? _rooms;

  BookingBloc({
    required this.createBookingUsecase,
    required this.getBookingByIdUsecase,
    required this.getBookingsUsecase,
    required this.createPaymentLinkUsecase,
    required this.checkPaymentStatusUsecase,
    required this.getPackagesUsecase,
    required this.getAllRooms,
  }) : super(const BookingInitial()) {
    on<BookingLoadPackages>(_onLoadPackages);
    on<BookingSelectPackage>(_onSelectPackage);
    on<BookingLoadRooms>(_onLoadRooms);
    on<BookingSelectRoom>(_onSelectRoom);
    on<BookingSelectDate>(_onSelectDate);
    on<BookingCreateBooking>(_onCreateBooking);
    on<BookingCreatePaymentLink>(_onCreatePaymentLink);
    on<BookingCheckPaymentStatus>(_onCheckPaymentStatus);
    on<BookingLoadById>(_onLoadById);
    on<BookingLoadAll>(_onLoadAll);
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
      emit(BookingPackagesLoaded(
        packages: packages,
        selectedPackageId: _selectedPackageId,
      ));
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
      emit(BookingPackagesLoaded(
        packages: currentState.packages,
        selectedPackageId: _selectedPackageId,
      ));
    }
    
    // If all selections are made, create summary state
    if (_selectedPackageId != null && _selectedRoomId != null && _selectedDate != null) {
      try {
        final package = _packages?.firstWhere((p) => p.id == _selectedPackageId);
        final room = _rooms?.firstWhere((r) => r.id == _selectedRoomId);
        
        if (package != null && room != null) {
          emit(BookingSummaryReady(
            packageId: _selectedPackageId!,
            roomId: _selectedRoomId!,
            startDate: _selectedDate!,
            package: package,
            room: room,
          ));
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
    emit(const BookingLoading());
    try {
      final rooms = await getAllRooms();
      // Filter only available rooms
      final availableRooms = rooms.where((r) => r.status == RoomStatus.available).toList();
      _rooms = availableRooms;
      emit(BookingRoomsLoaded(
        rooms: availableRooms,
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
      emit(BookingRoomsLoaded(
        rooms: currentState.rooms,
        selectedRoomId: _selectedRoomId,
      ));
    }
    
    // If all selections are made, create summary state
    if (_selectedPackageId != null && _selectedRoomId != null && _selectedDate != null) {
      try {
        final package = _packages?.firstWhere((p) => p.id == _selectedPackageId);
        final room = _rooms?.firstWhere((r) => r.id == _selectedRoomId);
        
        if (package != null && room != null) {
          emit(BookingSummaryReady(
            packageId: _selectedPackageId!,
            roomId: _selectedRoomId!,
            startDate: _selectedDate!,
            package: package,
            room: room,
          ));
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
    emit(BookingDateSelected(event.date));
    
    // If all selections are made, create summary state
    if (_selectedPackageId != null && _selectedRoomId != null && _selectedDate != null) {
      try {
        final package = _packages?.firstWhere((p) => p.id == _selectedPackageId);
        final room = _rooms?.firstWhere((r) => r.id == _selectedRoomId);
        
        if (package != null && room != null) {
          emit(BookingSummaryReady(
            packageId: _selectedPackageId!,
            roomId: _selectedRoomId!,
            startDate: _selectedDate!,
            package: package,
            room: room,
          ));
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
    if (_selectedPackageId == null || _selectedRoomId == null || _selectedDate == null) {
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

  Future<void> _onCreatePaymentLink(
    BookingCreatePaymentLink event,
    Emitter<BookingState> emit,
  ) async {
    final currentState = state;
    int? bookingId;

    // Support both BookingCreated and BookingLoaded states
    if (currentState is BookingCreated) {
      bookingId = currentState.booking.id;
    } else if (currentState is BookingLoaded) {
      bookingId = currentState.booking.id;
    } else {
      emit(const BookingError('Vui lòng tạo booking trước'));
      return;
    }

    emit(const BookingLoading());
    try {
      final paymentLink = await createPaymentLinkUsecase(
        bookingId: bookingId,
        type: event.type,
      );
      emit(BookingPaymentLinkCreated(paymentLink));
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
