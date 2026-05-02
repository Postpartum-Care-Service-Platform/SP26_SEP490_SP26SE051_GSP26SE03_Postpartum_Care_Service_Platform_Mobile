import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/create_booking_for_customer_usecase.dart';
import '../../domain/usecases/get_booking_by_id_usecase.dart';
import '../../domain/usecases/get_bookings_usecase.dart';
import '../../domain/usecases/create_payment_link_usecase.dart';
import '../../domain/usecases/check_payment_status_usecase.dart';
import '../../domain/usecases/confirm_completion_usecase.dart';
import '../../../package/domain/usecases/get_packages_usecase.dart';
import '../../../package/domain/entities/package_entity.dart';
import '../../../../../features/employee/room/domain/usecases/get_rooms_by_package.dart';
import '../../../../../features/employee/room/domain/entities/room_entity.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../../family_profile/domain/usecases/get_family_profiles_usecase.dart';
import '../../domain/usecases/get_booking_config_usecase.dart';
import '../../domain/usecases/check_staff_availability_usecase.dart';
import '../../domain/entities/booking_config_entity.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import '../../../../features/employee/account/data/models/account_model.dart';

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
  final GetMyCustomPackagesUsecase getMyCustomPackagesUsecase;
  final GetFamilyProfilesUsecase getFamilyProfilesUsecase;
  final GetRoomsByPackage getRoomsByPackage;
  final ConfirmCompletionUsecase confirmCompletionUsecase;
  final GetBookingConfigUsecase getBookingConfigUsecase;
  final CheckStaffAvailabilityUsecase checkStaffAvailabilityUsecase;

  // Current selection state
  int? _selectedPackageId;
  List<int> _selectedFamilyProfileIds = [];
  int? _selectedRoomId;
  DateTime? _selectedDate;
  List<PackageEntity>? _packages;
  List<FamilyProfileEntity>? _familyProfiles;
  List<RoomEntity>? _rooms;
  AccountModel? _selectedCustomer;
  BookingConfigEntity? _config;
  bool? _hasAvailableStaff;

  // Read-only accessors for UI to restore selections when navigating between steps
  DateTime? get selectedDate => _selectedDate;
  int? get selectedPackageId => _selectedPackageId;
  int? get selectedRoomId => _selectedRoomId;
  List<int> get selectedFamilyProfileIds => List.unmodifiable(_selectedFamilyProfileIds);
  List<FamilyProfileEntity>? get familyProfiles => _familyProfiles;
  PackageEntity? get selectedPackage {
    if (_selectedPackageId == null || _packages == null) return null;
    try {
      return _packages!.firstWhere((p) => p.id == _selectedPackageId);
    } catch (_) {
      return null;
    }
  }

  List<RoomEntity>? get rooms => _rooms;
  AccountModel? get selectedCustomer => _selectedCustomer;
  BookingConfigEntity? get config => _config;
  bool? get hasAvailableStaff => _hasAvailableStaff;

  BookingBloc({
    required this.createBookingUsecase,
    required this.cancelBookingUsecase,
    required this.createBookingForCustomerUsecase,
    required this.getBookingByIdUsecase,
    required this.getBookingsUsecase,
    required this.createPaymentLinkUsecase,
    required this.checkPaymentStatusUsecase,
    required this.getPackagesUsecase,
    required this.getMyCustomPackagesUsecase,
    required this.getFamilyProfilesUsecase,
    required this.getRoomsByPackage,
    required this.confirmCompletionUsecase,
    required this.getBookingConfigUsecase,
    required this.checkStaffAvailabilityUsecase,
  }) : super(const BookingInitial()) {
    on<BookingLoadPackages>(_onLoadPackages);
    on<BookingSelectPackage>(_onSelectPackage);
    on<BookingLoadFamilyProfiles>(_onLoadFamilyProfiles);
    on<BookingSelectFamilyProfiles>(_onSelectFamilyProfiles);
    on<BookingLoadRooms>(_onLoadRooms);
    on<BookingSelectRoom>(_onSelectRoom);
    on<BookingSelectDate>(_onSelectDate);
    on<BookingCreateBooking>(_onCreateBooking);
    on<BookingCreateBookingForCustomer>(_onCreateBookingForCustomer);
    on<BookingCreatePaymentLink>(_onCreatePaymentLink);
    on<BookingCheckPaymentStatus>(_onCheckPaymentStatus);
    on<BookingLoadById>(_onLoadById);
    on<BookingLoadAll>(_onLoadAll);
    on<BookingCancelRequested>(_onCancelBooking);
    on<BookingReset>(_onReset);
    on<BookingSelectCustomer>(_onSelectCustomer);
    on<BookingConfirmCompletion>(_onConfirmCompletion);
    on<BookingLoadConfig>(_onLoadConfig);
    on<BookingCheckStaffAvailability>(_onCheckStaffAvailability);
  }

  Future<void> _onLoadPackages(
    BookingLoadPackages event,
    Emitter<BookingState> emit,
  ) async {
    // Nếu đã có packages cached VÀ loại package (personalized hay không) trùng khớp, emit lại luôn
    // Tuy nhiên để đảm bảo mượt mà khi switch tab, ta cho phép load lại nếu type khác.
    // Để đơn giản, ta sẽ luôn load lại nếu event yêu cầu refresh hoặc type khác type hiện tại.
    
    if (state is BookingLoading) {
      return;
    }
 
    emit(const BookingLoading());
    try {
      final packages = event.isPersonalized 
          ? await getMyCustomPackagesUsecase()
          : await getPackagesUsecase();
      
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
    _selectedRoomId = null;
    _rooms = null;

    // Luôn emit BookingPackagesLoaded khi chọn/đổi gói
    if (_packages != null) {
      emit(
        BookingPackagesLoaded(
          packages: _packages!,
          selectedPackageId: _selectedPackageId,
        ),
      );
      return;
    }

    _emitSummaryIfReady(emit);
  }

  Future<void> _onLoadFamilyProfiles(
    BookingLoadFamilyProfiles event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final accountId = event.accountId?.trim();
      final profiles = (accountId != null && accountId.isNotEmpty)
          ? await getFamilyProfilesUsecase.byAccountId(accountId)
          : await getFamilyProfilesUsecase();
      _familyProfiles = profiles;

      if (_selectedFamilyProfileIds.isEmpty && profiles.isNotEmpty) {
        // Auto-select only Mẹ (memberTypeId=2) and Em bé (memberTypeId=3)
        final eligibleIds = profiles
            .where((p) => p.memberTypeId == 2 || p.memberTypeId == 3)
            .map((p) => p.id)
            .toList();
        if (eligibleIds.isNotEmpty) {
          _selectedFamilyProfileIds = eligibleIds;
        }
      }

      emit(
        BookingFamilyProfilesLoaded(
          profiles: profiles,
          selectedFamilyProfileIds: _selectedFamilyProfileIds,
        ),
      );
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onSelectFamilyProfiles(
    BookingSelectFamilyProfiles event,
    Emitter<BookingState> emit,
  ) async {
    _selectedFamilyProfileIds = event.familyProfileIds;

    final currentState = state;
    if (currentState is BookingFamilyProfilesLoaded) {
      emit(
        BookingFamilyProfilesLoaded(
          profiles: currentState.profiles,
          selectedFamilyProfileIds: _selectedFamilyProfileIds,
        ),
      );
      return;
    }

    // Nếu đang ở state khác (ví dụ vừa back từ step sau) nhưng đã có profiles cached,
    // emit lại BookingFamilyProfilesLoaded để UI step 2 có thể cập nhật checkbox mượt mà.
    if (_familyProfiles != null) {
      emit(
        BookingFamilyProfilesLoaded(
          profiles: _familyProfiles!,
          selectedFamilyProfileIds: _selectedFamilyProfileIds,
        ),
      );
      return;
    }

    _emitSummaryIfReady(emit);
  }

  Future<void> _onLoadRooms(
    BookingLoadRooms event,
    Emitter<BookingState> emit,
  ) async {
    if (_selectedPackageId == null) {
      emit(BookingError(AppStrings.bookingPleaseSelectPackage));
      return;
    }

    final startDate = event.startDate ?? _selectedDate;
    if (startDate == null) {
      emit(BookingError(AppStrings.bookingPleaseSelectDate));
      return;
    }

    PackageEntity? selectedPackage;
    if (_packages != null) {
      try {
        selectedPackage = _packages!.firstWhere((p) => p.id == _selectedPackageId);
      } catch (_) {
        selectedPackage = null;
      }
    }

    final durationDays = selectedPackage?.durationDays ?? 0;
    final fallbackEndDate = durationDays > 0
        ? startDate.add(Duration(days: durationDays))
        : startDate;
    final endDate = event.endDate ?? fallbackEndDate;

    emit(const BookingLoading());
    try {
      final rooms = await getRoomsByPackage(
        packageId: _selectedPackageId!,
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
      return;
    }

    _emitSummaryIfReady(emit);
  }

  Future<void> _onSelectDate(
    BookingSelectDate event,
    Emitter<BookingState> emit,
  ) async {
    _selectedDate = event.date;
    _hasAvailableStaff = null; // Reset availability when date changes
    PackageEntity? package;
    if (_selectedPackageId != null && _packages != null) {
      try {
        package = _packages!.firstWhere((p) => p.id == _selectedPackageId);
      } catch (_) {
        package = null;
      }
    }
    emit(BookingDateSelected(event.date, package: package));
  }

  Future<void> _onCreateBooking(
    BookingCreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    if (_selectedPackageId == null ||
        _selectedRoomId == null ||
        _selectedDate == null ||
        _selectedFamilyProfileIds.isEmpty) {
      emit(BookingError(AppStrings.errorFillAllFields));
      return;
    }

    emit(const BookingLoading());
    try {
      final booking = await createBookingUsecase(
        packageId: _selectedPackageId!,
        roomId: _selectedRoomId!,
        startDate: _selectedDate!,
        familyProfileIds: _selectedFamilyProfileIds,
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
        _selectedDate == null ||
        event.familyProfileIds.isEmpty) {
      emit(BookingError(AppStrings.homeServicePleaseCompleteInfo));
      return;
    }

    emit(const BookingLoading());
    try {
      final booking = await createBookingForCustomerUsecase(
        customerId: event.customerId,
        packageId: _selectedPackageId!,
        roomId: _selectedRoomId!,
        startDate: _selectedDate!,
        familyProfileIds: event.familyProfileIds,
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
      if (currentState is BookingCreated) {
        bookingId = currentState.booking.id;
      } else if (currentState is BookingLoaded) {
        bookingId = currentState.booking.id;
      } else {
        emit(BookingError(AppStrings.homeServicePleaseCreateBookingFirst));
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

      // Attempt to fetch family profiles to augment booking data with avatars
      try {
        final profiles = await getFamilyProfilesUsecase();
        final updatedTargetBookings = booking.targetBookings.map((target) {
          final matchingProfiles =
              profiles.where((p) => p.id == target.familyProfileId);
          if (matchingProfiles.isNotEmpty) {
            final profile = matchingProfiles.first;
            // Only update if current target doesn't have an avatar but profile does
            if ((target.avatarUrl == null || target.avatarUrl!.isEmpty) &&
                profile.avatarUrl != null &&
                profile.avatarUrl!.isNotEmpty) {
              return target.copyWith(avatarUrl: profile.avatarUrl);
            }
          }
          return target;
        }).toList();

        final updatedBooking =
            booking.copyWith(targetBookings: updatedTargetBookings);
        emit(BookingLoaded(updatedBooking));
      } catch (_) {
        // Fallback to original booking data if profile fetch fails
        emit(BookingLoaded(booking));
      }
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

  Future<void> _onConfirmCompletion(
    BookingConfirmCompletion event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final message = await confirmCompletionUsecase(event.id);
      emit(BookingConfirmCompletionSuccess(bookingId: event.id, message: message));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onReset(
    BookingReset event,
    Emitter<BookingState> emit,
  ) async {
    _selectedPackageId = null;
    _selectedFamilyProfileIds = [];
    _selectedRoomId = null;
    _selectedDate = null;
    _selectedCustomer = null;
    _packages = null;
    _familyProfiles = null;
    _rooms = null;
    emit(const BookingInitial());
  }

  void _emitSummaryIfReady(Emitter<BookingState> emit) {
    if (_selectedPackageId == null ||
        _selectedRoomId == null ||
        _selectedDate == null ||
        _selectedFamilyProfileIds.isEmpty) {
      return;
    }

    try {
      final package = _packages?.firstWhere((p) => p.id == _selectedPackageId);
      final room = _rooms?.firstWhere((r) => r.id == _selectedRoomId);

      if (package != null && room != null) {
        emit(
          BookingSummaryReady(
            packageId: _selectedPackageId!,
            roomId: _selectedRoomId!,
            startDate: _selectedDate!,
            familyProfileIds: _selectedFamilyProfileIds,
            package: package,
            room: room,
          ),
        );
      }
    } catch (_) {
      // Ignore if package/room not found
    }
  }

  void _onSelectCustomer(BookingSelectCustomer event, Emitter<BookingState> emit) {
    if (event.customer is AccountModel) {
      _selectedCustomer = event.customer as AccountModel;
    }
  }

  Future<void> _onLoadConfig(
    BookingLoadConfig event,
    Emitter<BookingState> emit,
  ) async {
    try {
      final config = await getBookingConfigUsecase();
      _config = config;
      emit(BookingConfigLoaded(config));
    } catch (_) {
      // Nếu lỗi thì giữ giá trị mặc định (null) hoặc log
    }
  }

  Future<void> _onCheckStaffAvailability(
    BookingCheckStaffAvailability event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingCheckingStaffAvailability());
    try {
      final availability = await checkStaffAvailabilityUsecase(
        from: event.from,
        to: event.to,
      );
      _hasAvailableStaff = availability.hasAvailableStaff;
      emit(BookingStaffAvailabilityChecked(
        hasAvailableStaff: availability.hasAvailableStaff,
        availableCount: availability.availableCount,
        message: availability.hasAvailableStaff 
            ? null 
            : 'Hiện tại trung tâm không còn nhân viên để phục vụ vào thời gian này. Vui lòng chọn ngày khác.',
      ));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
