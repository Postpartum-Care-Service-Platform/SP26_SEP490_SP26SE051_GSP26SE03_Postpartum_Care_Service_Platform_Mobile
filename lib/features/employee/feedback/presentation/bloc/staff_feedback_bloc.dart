import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_feedbacks_for_staff.dart';
import 'staff_feedback_event.dart';
import 'staff_feedback_state.dart';

class StaffFeedbackBloc extends Bloc<StaffFeedbackEvent, StaffFeedbackState> {
  final GetMyFeedbacksForStaffUseCase getMyFeedbacksForStaffUseCase;

  StaffFeedbackBloc({required this.getMyFeedbacksForStaffUseCase})
      : super(StaffFeedbackInitial()) {
    on<FetchStaffFeedbacksEvent>(_onFetchStaffFeedbacks);
  }

  Future<void> _onFetchStaffFeedbacks(
    FetchStaffFeedbacksEvent event,
    Emitter<StaffFeedbackState> emit,
  ) async {
    emit(StaffFeedbackLoading());
    try {
      final feedbacks = await getMyFeedbacksForStaffUseCase();
      // sort by desc createdAt
      feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(StaffFeedbackLoaded(feedbacks));
    } catch (e) {
      emit(StaffFeedbackError(e.toString()));
    }
  }
}
