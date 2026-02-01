import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_feedback_types_usecase.dart';
import '../../domain/usecases/get_my_feedbacks_usecase.dart';
import '../../domain/usecases/create_feedback_usecase.dart';
import 'feedback_event.dart';
import 'feedback_state.dart';

/// Feedback BLoC
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final GetFeedbackTypesUsecase getFeedbackTypesUsecase;
  final GetMyFeedbacksUsecase getMyFeedbacksUsecase;
  final CreateFeedbackUsecase createFeedbackUsecase;

  FeedbackBloc({
    required this.getFeedbackTypesUsecase,
    required this.getMyFeedbacksUsecase,
    required this.createFeedbackUsecase,
  }) : super(const FeedbackInitial()) {
    on<FeedbackTypesLoadRequested>(_onFeedbackTypesLoadRequested);
    on<MyFeedbacksLoadRequested>(_onMyFeedbacksLoadRequested);
    on<MyFeedbacksRefreshRequested>(_onMyFeedbacksRefreshRequested);
    on<FeedbackCreateRequested>(_onFeedbackCreateRequested);
  }

  Future<void> _onFeedbackTypesLoadRequested(
    FeedbackTypesLoadRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    try {
      final types = await getFeedbackTypesUsecase();
      emit(FeedbackTypesLoaded(types: types));
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> _onMyFeedbacksLoadRequested(
    MyFeedbacksLoadRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(const FeedbackLoading());
    try {
      final types = await getFeedbackTypesUsecase();
      final feedbacks = await getMyFeedbacksUsecase();
      emit(MyFeedbacksLoaded(feedbacks: feedbacks, types: types));
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> _onMyFeedbacksRefreshRequested(
    MyFeedbacksRefreshRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    if (state is MyFeedbacksLoaded) {
      final currentState = state as MyFeedbacksLoaded;
      try {
        final feedbacks = await getMyFeedbacksUsecase();
        emit(currentState.copyWith(feedbacks: feedbacks));
      } catch (e) {
        emit(FeedbackError(e.toString()));
      }
    } else {
      add(const MyFeedbacksLoadRequested());
    }
  }

  Future<void> _onFeedbackCreateRequested(
    FeedbackCreateRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(const FeedbackLoading());
    try {
      final feedback = await createFeedbackUsecase(
        feedbackTypeId: event.feedbackTypeId,
        title: event.title,
        content: event.content,
        rating: event.rating,
        imagePaths: event.imagePaths,
      );
      emit(FeedbackCreated(feedback: feedback));
      // Reload feedbacks after creation
      add(const MyFeedbacksLoadRequested());
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }
}
