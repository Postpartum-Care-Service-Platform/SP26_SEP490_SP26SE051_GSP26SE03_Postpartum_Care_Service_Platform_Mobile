import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_care_plan_details_usecase.dart';
import 'care_plan_event.dart';
import 'care_plan_state.dart';

/// Care Plan BloC
class CarePlanBloc extends Bloc<CarePlanEvent, CarePlanState> {
  final GetCarePlanDetailsUsecase getCarePlanDetailsUsecase;

  CarePlanBloc({
    required this.getCarePlanDetailsUsecase,
  }) : super(const CarePlanInitial()) {
    on<CarePlanLoadRequested>(_onLoadRequested);
    on<CarePlanRefresh>(_onRefresh);
  }

  Future<void> _onLoadRequested(
    CarePlanLoadRequested event,
    Emitter<CarePlanState> emit,
  ) async {
    emit(const CarePlanLoading());
    try {
      final carePlans = await getCarePlanDetailsUsecase(event.packageId);
      final packageName = carePlans.isNotEmpty ? carePlans.first.packageName : '';
      emit(CarePlanLoaded(
        carePlans: carePlans,
        packageName: packageName,
      ));
    } catch (e) {
      emit(CarePlanError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    CarePlanRefresh event,
    Emitter<CarePlanState> emit,
  ) async {
    try {
      final carePlans = await getCarePlanDetailsUsecase(event.packageId);
      final packageName = carePlans.isNotEmpty ? carePlans.first.packageName : '';
      emit(CarePlanLoaded(
        carePlans: carePlans,
        packageName: packageName,
      ));
    } catch (e) {
      emit(CarePlanError(e.toString()));
    }
  }
}
