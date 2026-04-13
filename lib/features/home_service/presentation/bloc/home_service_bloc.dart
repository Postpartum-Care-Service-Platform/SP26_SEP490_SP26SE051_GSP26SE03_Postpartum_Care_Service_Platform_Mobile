import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/get_home_activities_usecase.dart';
import '../../domain/usecases/get_free_home_staff_usecase.dart';
import '../../domain/usecases/book_home_service_usecase.dart';
import '../../domain/usecases/create_home_service_payment_link_usecase.dart';
import '../../domain/usecases/check_payment_status_usecase.dart';
import '../../domain/entities/home_activity_entity.dart';
import '../../domain/entities/home_service_selection_entity.dart';
import '../../domain/entities/home_staff_entity.dart';
import '../../data/datasources/home_service_remote_datasource.dart';
import 'home_service_event.dart';
import 'home_service_state.dart';

/// Home Service Booking BloC
class HomeServiceBloc extends Bloc<HomeServiceEvent, HomeServiceState> {
  final GetHomeActivitiesUsecase getHomeActivitiesUsecase;
  final GetFreeHomeStaffUsecase getFreeHomeStaffUsecase;
  final BookHomeServiceUsecase bookHomeServiceUsecase;
  final CreateHomeServicePaymentLinkUsecase createPaymentLinkUsecase;
  final CheckPaymentStatusUsecase checkPaymentStatusUsecase;

  // Current selection state
  List<HomeActivityEntity> _activities = [];
  List<HomeServiceSelectionEntity> _selections = [];
  List<HomeStaffEntity> _staffList = [];
  HomeStaffEntity? _selectedStaff;

  HomeServiceBloc({
    required this.getHomeActivitiesUsecase,
    required this.getFreeHomeStaffUsecase,
    required this.bookHomeServiceUsecase,
    required this.createPaymentLinkUsecase,
    required this.checkPaymentStatusUsecase,
  }) : super(const HomeServiceInitial()) {
    on<HomeServiceLoadActivities>(_onLoadActivities);
    on<HomeServiceToggleActivitySelection>(_onToggleActivitySelection);
    on<HomeServiceSelectActivityAndDate>(_onSelectActivityAndDate);
    on<HomeServiceRemoveActivityDate>(_onRemoveActivityDate);
    on<HomeServiceSelectTime>(_onSelectTime);
    on<HomeServiceLoadFreeStaff>(_onLoadFreeStaff);
    on<HomeServiceSelectStaff>(_onSelectStaff);
    on<HomeServiceClearSelectedStaff>(_onClearSelectedStaff);
    on<HomeServicePrepareSummary>(_onPrepareSummary);
    on<HomeServiceBackToStaffSelection>(_onBackToStaffSelection);
    on<HomeServiceCreateBooking>(_onCreateBooking);
    on<HomeServiceCreatePaymentLink>(_onCreatePaymentLink);
    on<HomeServiceCheckPaymentStatus>(_onCheckPaymentStatus);
    on<HomeServiceCancelBooking>(_onCancelBooking);
    on<HomeServiceReset>(_onReset);
  }

  Future<void> _onLoadActivities(
    HomeServiceLoadActivities event,
    Emitter<HomeServiceState> emit,
  ) async {
    emit(const HomeServiceLoading());
    try {
      _activities = await getHomeActivitiesUsecase();
      emit(HomeServiceActivitiesLoaded(
        activities: List<HomeActivityEntity>.from(_activities),
        selections: List<HomeServiceSelectionEntity>.from(_selections),
      ));
    } catch (e) {
      emit(HomeServiceError(e.toString()));
    }
  }

  void _onToggleActivitySelection(
    HomeServiceToggleActivitySelection event,
    Emitter<HomeServiceState> emit,
  ) {
    final updatedSelections = List<HomeServiceSelectionEntity>.from(_selections);
    final existingIndex = updatedSelections.indexWhere(
      (s) => s.activity.id == event.activity.id,
    );

    if (existingIndex >= 0) {
      updatedSelections.removeAt(existingIndex);
    } else {
      updatedSelections.add(
        HomeServiceSelectionEntity(
          activity: event.activity,
          dateTimeSlots: {},
        ),
      );
    }

    _selections = updatedSelections;

    emit(HomeServiceActivitiesLoaded(
      activities: List<HomeActivityEntity>.from(_activities),
      selections: List<HomeServiceSelectionEntity>.from(_selections),
    ));
  }

  void _onSelectActivityAndDate(
    HomeServiceSelectActivityAndDate event,
    Emitter<HomeServiceState> emit,
  ) {
    final existingIndex = _selections.indexWhere(
      (s) => s.activity.id == event.activity.id,
    );

    if (existingIndex < 0) {
      _selections.add(
        HomeServiceSelectionEntity(
          activity: event.activity,
          dateTimeSlots: {},
        ),
      );
    }

    final index = _selections.indexWhere((s) => s.activity.id == event.activity.id);
    final existing = _selections[index];
    final newSlots = Map<DateTime, ServiceTimeSlot>.from(existing.dateTimeSlots);

    if (!newSlots.containsKey(event.date)) {
      final duration = Duration(minutes: event.activity.duration);
      final slot = _findNextFreeSlot(event.date, duration, event.activity.id);

      if (_hasOverlap(event.date, slot.startTime, slot.endTime, event.activity.id)) {
        emit(const HomeServiceError('Ngày bạn chọn đã quá kín lịch các dịch vụ khác, hãy chọn ngày giờ khác.'));
        // Re-emit loaded so UI recovers
        emit(HomeServiceActivitiesLoaded(
          activities: List<HomeActivityEntity>.from(_activities),
          selections: List<HomeServiceSelectionEntity>.from(_selections),
        ));
        return;
      }

      newSlots[event.date] = slot;

      _selections[index] = HomeServiceSelectionEntity(
        activity: existing.activity,
        dateTimeSlots: newSlots,
      );
    }

    emit(HomeServiceActivitiesLoaded(
      activities: List<HomeActivityEntity>.from(_activities),
      selections: List<HomeServiceSelectionEntity>.from(_selections),
    ));
  }

  void _onRemoveActivityDate(
    HomeServiceRemoveActivityDate event,
    Emitter<HomeServiceState> emit,
  ) {
    final existingIndex = _selections.indexWhere(
      (s) => s.activity.id == event.activity.id,
    );

    if (existingIndex >= 0) {
      final existing = _selections[existingIndex];
      final newSlots = Map<DateTime, ServiceTimeSlot>.from(existing.dateTimeSlots);
      newSlots.remove(event.date);

      _selections[existingIndex] = HomeServiceSelectionEntity(
        activity: existing.activity,
        dateTimeSlots: newSlots,
      );
    }

    emit(HomeServiceActivitiesLoaded(
      activities: List<HomeActivityEntity>.from(_activities),
      selections: List<HomeServiceSelectionEntity>.from(_selections),
    ));
  }

  void _onSelectTime(
    HomeServiceSelectTime event,
    Emitter<HomeServiceState> emit,
  ) {
    final existingIndex = _selections.indexWhere(
      (s) => s.activity.id == event.activity.id,
    );

    if (existingIndex >= 0) {
      final existing = _selections[existingIndex];
      final duration = event.endTime.difference(event.startTime);

      final newSlots = Map<DateTime, ServiceTimeSlot>.from(existing.dateTimeSlots);

      if (event.applyToAll) {
        // First validate ALL dates to ensure no overlaps
        for (final date in newSlots.keys.toList()) {
          final start = DateTime(
            date.year,
            date.month,
            date.day,
            event.startTime.hour,
            event.startTime.minute,
          );
          final end = start.add(duration);

          if (_hasOverlap(date, start, end, event.activity.id)) {
            emit(const HomeServiceError('Khung giờ này trùng với dịch vụ khác trong cùng một ngày! Vui lòng chọn giờ khác.'));
            emit(HomeServiceActivitiesLoaded(
              activities: List<HomeActivityEntity>.from(_activities),
              selections: List<HomeServiceSelectionEntity>.from(_selections),
            ));
            return;
          }
        }

        // Apply the new time slot to ALL selected dates since validation passed
        for (final date in newSlots.keys.toList()) {
          final start = DateTime(
            date.year,
            date.month,
            date.day,
            event.startTime.hour,
            event.startTime.minute,
          );
          final end = start.add(duration);
          newSlots[date] = ServiceTimeSlot(
            startTime: start,
            endTime: end,
          );
        }
      } else {
        // Only apply the new time slot to the specific date selected
        final normalizedDate = DateTime(event.date.year, event.date.month, event.date.day);
        if (newSlots.containsKey(normalizedDate)) {
          final start = DateTime(
            normalizedDate.year,
            normalizedDate.month,
            normalizedDate.day,
            event.startTime.hour,
            event.startTime.minute,
          );
          final end = start.add(duration);

          if (_hasOverlap(normalizedDate, start, end, event.activity.id)) {
            emit(const HomeServiceError('Khung giờ này trùng với dịch vụ khác trong cùng một ngày! Vui lòng chọn giờ khác.'));
            emit(HomeServiceActivitiesLoaded(
              activities: List<HomeActivityEntity>.from(_activities),
              selections: List<HomeServiceSelectionEntity>.from(_selections),
            ));
            return;
          }

          newSlots[normalizedDate] = ServiceTimeSlot(
            startTime: start,
            endTime: end,
          );
        }
      }

      _selections[existingIndex] = HomeServiceSelectionEntity(
        activity: existing.activity,
        dateTimeSlots: newSlots,
      );
    }

    emit(HomeServiceActivitiesLoaded(
      activities: List<HomeActivityEntity>.from(_activities),
      selections: List<HomeServiceSelectionEntity>.from(_selections),
    ));
  }

  Future<void> _onLoadFreeStaff(
    HomeServiceLoadFreeStaff event,
    Emitter<HomeServiceState> emit,
  ) async {
    if (_selections.isEmpty) {
      emit(const HomeServiceError(AppStrings.homeServicePleaseSelectServiceAndDate));
      return;
    }

    // Build availability requests from selections
    final requests = <StaffAvailabilityRequest>[];
    for (final selection in _selections) {
      for (final entry in selection.dateTimeSlots.entries) {
        requests.add(StaffAvailabilityRequest(
          date: entry.key,
          startTime: entry.value.startTime,
          endTime: entry.value.endTime,
        ));
      }
    }

    emit(const HomeServiceLoading());
    try {
      _staffList = await getFreeHomeStaffUsecase(requests);
      emit(HomeServiceFreeStaffLoaded(
        activities: _activities,
        selections: _selections,
        staffList: _staffList,
        selectedStaff: _selectedStaff,
      ));
    } catch (e) {
      emit(HomeServiceError(e.toString()));
    }
  }

  void _onSelectStaff(
    HomeServiceSelectStaff event,
    Emitter<HomeServiceState> emit,
  ) {
    _selectedStaff = event.staff;

    emit(HomeServiceFreeStaffLoaded(
      activities: List<HomeActivityEntity>.from(_activities),
      selections: List<HomeServiceSelectionEntity>.from(_selections),
      staffList: List<HomeStaffEntity>.from(_staffList),
      selectedStaff: _selectedStaff,
    ));
  }

  void _onClearSelectedStaff(
    HomeServiceClearSelectedStaff event,
    Emitter<HomeServiceState> emit,
  ) {
    _selectedStaff = null;
    emit(HomeServiceActivitiesLoaded(
      activities: List<HomeActivityEntity>.from(_activities),
      selections: List<HomeServiceSelectionEntity>.from(_selections),
    ));
  }

  void _onPrepareSummary(
    HomeServicePrepareSummary event,
    Emitter<HomeServiceState> emit,
  ) {
    if (_selectedStaff == null || _selections.isEmpty) {
      emit(const HomeServiceError(AppStrings.homeServicePleaseCompleteInfo));
      return;
    }

    double totalPrice = 0;
    for (final selection in _selections) {
      final sessions = selection.dateTimeSlots.length;
      final price = selection.activity.price ?? 0;
      totalPrice += price * (sessions > 0 ? sessions : 1);
    }

    emit(HomeServiceSummaryReady(
      activities: List<HomeActivityEntity>.from(_activities),
      selections: List<HomeServiceSelectionEntity>.from(_selections),
      staff: _selectedStaff!,
      totalPrice: totalPrice,
    ));
  }

  void _onBackToStaffSelection(
    HomeServiceBackToStaffSelection event,
    Emitter<HomeServiceState> emit,
  ) {
    emit(HomeServiceFreeStaffLoaded(
      activities: List<HomeActivityEntity>.from(_activities),
      selections: List<HomeServiceSelectionEntity>.from(_selections),
      staffList: List<HomeStaffEntity>.from(_staffList),
      selectedStaff: _selectedStaff,
    ));
  }

  Future<void> _onCreateBooking(
    HomeServiceCreateBooking event,
    Emitter<HomeServiceState> emit,
  ) async {
    if (_selectedStaff == null || _selections.isEmpty) {
      emit(const HomeServiceError(AppStrings.homeServicePleaseCompleteInfo));
      return;
    }

    emit(const HomeServiceLoading());
    try {
      final booking = await bookHomeServiceUsecase(
        staffId: _selectedStaff!.id,
        selections: _selections,
      );

      final normalizedBooking = booking.staffId.isNotEmpty
          ? booking
          : booking.copyWith(staffId: _selectedStaff!.id);

      emit(HomeServiceBookingCreated(normalizedBooking));
    } catch (e) {
      emit(HomeServiceError(e.toString()));
    }
  }

  Future<void> _onCreatePaymentLink(
    HomeServiceCreatePaymentLink event,
    Emitter<HomeServiceState> emit,
  ) async {
    final currentState = state;
    int? bookingId;
    String? staffId;

    if (currentState is HomeServiceBookingCreated) {
      bookingId = currentState.booking.id;
      staffId = currentState.booking.staffId;
    } else {
      emit(const HomeServiceError(AppStrings.homeServicePleaseCreateBookingFirst));
      return;
    }

    emit(const HomeServiceLoading());
    try {
      final paymentLink = await createPaymentLinkUsecase(
        bookingId: bookingId,
        type: event.type,
        staffId: staffId,
      );
      emit(HomeServicePaymentLinkCreated(paymentLink));
    } catch (e) {
      emit(HomeServiceError(e.toString()));
    }
  }

  Future<void> _onCheckPaymentStatus(
    HomeServiceCheckPaymentStatus event,
    Emitter<HomeServiceState> emit,
  ) async {
    emit(const HomeServiceLoading());
    try {
      final paymentStatus = await checkPaymentStatusUsecase(event.orderCode);
      emit(HomeServicePaymentStatusChecked(paymentStatus));
    } catch (e) {
      emit(HomeServiceError(e.toString()));
    }
  }

  Future<void> _onCancelBooking(
    HomeServiceCancelBooking event,
    Emitter<HomeServiceState> emit,
  ) async {
    emit(const HomeServiceLoading());
    try {
      emit(const HomeServiceBookingCancelled(
        bookingId: 0,
        message: AppStrings.homeServiceCancelBookingSuccess,
      ));
    } catch (e) {
      emit(HomeServiceError(e.toString()));
    }
  }

  void _onReset(
    HomeServiceReset event,
    Emitter<HomeServiceState> emit,
  ) {
    _activities = [];
    _selections = [];
    _staffList = [];
    _selectedStaff = null;
    emit(const HomeServiceInitial());
  }

  /// Helper: Check if a given timeframe overlaps with ANY OTHER activity on the exact same date
  bool _hasOverlap(DateTime date, DateTime start, DateTime end, int ignoreActivityId) {
    for (final selection in _selections) {
      if (selection.activity.id == ignoreActivityId) continue;
      
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (selection.dateTimeSlots.containsKey(normalizedDate)) {
        final otherSlot = selection.dateTimeSlots[normalizedDate]!;
        // Overlap happens if Min(end1, end2) > Max(start1, start2)
        // Mathematically: start1 < end2 && end1 > start2
        if (start.isBefore(otherSlot.endTime) && end.isAfter(otherSlot.startTime)) {
          return true; // Overlap detected
        }
      }
    }
    return false;
  }

  /// Helper: Automatically resolve the earliest possible free time slot starting from 8:00
  ServiceTimeSlot _findNextFreeSlot(DateTime date, Duration duration, int ignoreActivityId) {
    DateTime candidateStart = DateTime(date.year, date.month, date.day, 8, 0);

    // Limit automatic search up until 8:00 PM (20:00)
    while (candidateStart.hour <= 20) {
      final candidateEnd = candidateStart.add(duration);
      if (!_hasOverlap(date, candidateStart, candidateEnd, ignoreActivityId)) {
        return ServiceTimeSlot(startTime: candidateStart, endTime: candidateEnd);
      }
      // If overlaps, try shifting by 30 mins
      candidateStart = candidateStart.add(const Duration(minutes: 30));
    }

    // Fallback if the whole day is practically fully booked. Returns default 8:00 to reliably fail overlap check later.
    return ServiceTimeSlot(
      startTime: DateTime(date.year, date.month, date.day, 8, 0),
      endTime: DateTime(date.year, date.month, date.day, 8, 0).add(duration),
    );
  }
}
