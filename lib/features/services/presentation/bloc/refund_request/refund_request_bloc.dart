import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_refund_request_usecase.dart';
import '../../../domain/usecases/create_home_staff_withdraw_request_usecase.dart';
import '../../../domain/usecases/get_my_refund_requests_usecase.dart';
import 'refund_request_event.dart';
import 'refund_request_state.dart';

/// Refund Request BLoC
class RefundRequestBloc extends Bloc<RefundRequestEvent, RefundRequestState> {
  final CreateRefundRequestUsecase createRefundRequestUsecase;
  final CreateHomeStaffWithdrawRequestUseCase
      createHomeStaffWithdrawRequestUseCase;
  final GetMyRefundRequestsUsecase getMyRefundRequestsUsecase;

  RefundRequestBloc({
    required this.createRefundRequestUsecase,
    required this.createHomeStaffWithdrawRequestUseCase,
    required this.getMyRefundRequestsUsecase,
  }) : super(const RefundRequestInitial()) {
    on<RefundRequestCreateRequested>(_onCreateRefundRequest);
    on<HomeStaffWithdrawRequested>(_onHomeStaffWithdrawRequested);
    on<RefundRequestLoadMyRequests>(_onLoadMyRequests);
  }

  Future<void> _onCreateRefundRequest(
    RefundRequestCreateRequested event,
    Emitter<RefundRequestState> emit,
  ) async {
    emit(const RefundRequestLoading());
    try {
      final requests = await createRefundRequestUsecase(
        bookingId: event.bookingId,
        bankName: event.bankName,
        accountNumber: event.accountNumber,
        accountHolder: event.accountHolder,
        reason: event.reason,
      );
      emit(RefundRequestCreated(requests: requests));
    } catch (e) {
      emit(RefundRequestError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onHomeStaffWithdrawRequested(
    HomeStaffWithdrawRequested event,
    Emitter<RefundRequestState> emit,
  ) async {
    emit(const RefundRequestLoading());
    try {
      final requests = await createHomeStaffWithdrawRequestUseCase.execute(
        requestedAmount: event.requestedAmount,
        bankName: event.bankName,
        accountNumber: event.accountNumber,
        accountHolder: event.accountHolder,
        reason: event.reason,
      );
      emit(RefundRequestCreated(requests: requests));
    } catch (e) {
      emit(RefundRequestError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadMyRequests(
    RefundRequestLoadMyRequests event,
    Emitter<RefundRequestState> emit,
  ) async {
    emit(const RefundRequestLoading());
    try {
      final requests = await getMyRefundRequestsUsecase();
      emit(RefundRequestLoaded(requests: requests));
    } catch (e) {
      emit(RefundRequestError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
