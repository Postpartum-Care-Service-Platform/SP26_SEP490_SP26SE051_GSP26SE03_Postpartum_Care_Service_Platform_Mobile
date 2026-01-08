import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/family_profile_entity.dart';
import '../../data/models/member_type_model.dart';
import '../../data/models/create_family_profile_request_model.dart';
import '../../domain/usecases/get_family_profiles_usecase.dart';
import '../../domain/usecases/get_member_types_usecase.dart';
import '../../domain/usecases/create_family_profile_usecase.dart';

part 'family_profile_event.dart';
part 'family_profile_state.dart';

/// Bloc for managing family profiles list & metadata
class FamilyProfileBloc extends Bloc<FamilyProfileEvent, FamilyProfileState> {
  final GetFamilyProfilesUsecase getFamilyProfilesUsecase;
  final GetMemberTypesUsecase getMemberTypesUsecase;
  final CreateFamilyProfileUsecase createFamilyProfileUsecase;

  FamilyProfileBloc({
    required this.getFamilyProfilesUsecase,
    required this.getMemberTypesUsecase,
    required this.createFamilyProfileUsecase,
  }) : super(const FamilyProfileState.initial()) {
    on<FamilyProfileStarted>(_onStarted);
    on<FamilyProfileRefreshed>(_onRefreshed);
    on<FamilyProfileCreated>(_onCreated);
  }

  Future<void> _onStarted(
    FamilyProfileStarted event,
    Emitter<FamilyProfileState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    FamilyProfileRefreshed event,
    Emitter<FamilyProfileState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<FamilyProfileState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final profiles = await getFamilyProfilesUsecase();
      final memberTypes = await getMemberTypesUsecase();

      emit(
        state.copyWith(
          isLoading: false,
          members: profiles,
          memberTypes: memberTypes,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onCreated(
    FamilyProfileCreated event,
    Emitter<FamilyProfileState> emit,
  ) async {
    try {
      await createFamilyProfileUsecase(event.request);
      // Reload data after successful creation
      await _loadData(emit);
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}

