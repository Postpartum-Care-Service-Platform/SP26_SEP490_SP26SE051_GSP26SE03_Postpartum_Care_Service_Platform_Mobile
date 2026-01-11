import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_packages_usecase.dart';
import 'package_event.dart';
import 'package_state.dart';

/// Package BloC
class PackageBloc extends Bloc<PackageEvent, PackageState> {
  final GetPackagesUsecase getPackagesUsecase;

  PackageBloc({
    required this.getPackagesUsecase,
  }) : super(const PackageInitial()) {
    on<PackageLoadRequested>(_onLoadRequested);
    on<PackageRefresh>(_onRefresh);
  }

  Future<void> _onLoadRequested(
    PackageLoadRequested event,
    Emitter<PackageState> emit,
  ) async {
    emit(const PackageLoading());
    try {
      final packages = await getPackagesUsecase();
      emit(PackageLoaded(packages: packages));
    } catch (e) {
      emit(PackageError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    PackageRefresh event,
    Emitter<PackageState> emit,
  ) async {
    try {
      final packages = await getPackagesUsecase();
      emit(PackageLoaded(packages: packages));
    } catch (e) {
      emit(PackageError(e.toString()));
    }
  }
}
