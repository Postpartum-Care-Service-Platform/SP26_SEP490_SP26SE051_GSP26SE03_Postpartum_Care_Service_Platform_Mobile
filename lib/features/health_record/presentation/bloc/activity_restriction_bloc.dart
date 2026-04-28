import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/activity_restriction_repository.dart';
import 'activity_restriction_event.dart';
import 'activity_restriction_state.dart';

class ActivityRestrictionBloc extends Bloc<ActivityRestrictionEvent, ActivityRestrictionState> {
  final ActivityRestrictionRepository repository;

  ActivityRestrictionBloc({required this.repository}) : super(ActivityRestrictionInitial()) {
    on<CheckActivityRestriction>(_onCheckActivityRestriction);
    on<BatchCheckActivityRestrictions>(_onBatchCheckActivityRestrictions);
  }

  Future<void> _onCheckActivityRestriction(
    CheckActivityRestriction event,
    Emitter<ActivityRestrictionState> emit,
  ) async {
    emit(ActivityRestrictionLoading());
    try {
      final restriction = await repository.checkRestriction(
        event.familyProfileId,
        event.activityId,
      );
      emit(ActivityRestrictionChecked(restriction));
    } catch (e) {
      emit(ActivityRestrictionError(e.toString()));
    }
  }

  Future<void> _onBatchCheckActivityRestrictions(
    BatchCheckActivityRestrictions event,
    Emitter<ActivityRestrictionState> emit,
  ) async {
    emit(ActivityRestrictionLoading());
    try {
      final restrictions = await repository.batchCheckRestrictions(
        event.familyProfileId,
        event.activityIds,
      );
      emit(BatchActivityRestrictionsChecked(restrictions));
    } catch (e) {
      emit(ActivityRestrictionError(e.toString()));
    }
  }
}
