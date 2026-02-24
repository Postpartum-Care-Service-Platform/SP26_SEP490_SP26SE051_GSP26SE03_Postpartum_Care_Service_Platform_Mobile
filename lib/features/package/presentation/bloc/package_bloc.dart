import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/package_entity.dart';
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
    on<PackageFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    PackageLoadRequested event,
    Emitter<PackageState> emit,
  ) async {
    // Prevent duplicate API calls if already loading or loaded
    if (state is PackageLoading || state is PackageLoaded) {
      return;
    }
    
    emit(const PackageLoading());
    try {
      final packages = await getPackagesUsecase();
      final categorized = _categorizePackages(packages);
      emit(PackageLoaded(
        centerPackages: categorized.centerPackages,
        homePackages: categorized.homePackages,
        currentFilter: PackageFilter.center,
      ));
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
      final categorized = _categorizePackages(packages);
      final currentState = state;
      if (currentState is PackageLoaded) {
        emit(PackageLoaded(
          centerPackages: categorized.centerPackages,
          homePackages: categorized.homePackages,
          currentFilter: currentState.currentFilter,
        ));
      } else {
        emit(PackageLoaded(
          centerPackages: categorized.centerPackages,
          homePackages: categorized.homePackages,
          currentFilter: PackageFilter.center,
        ));
      }
    } catch (e) {
      emit(PackageError(e.toString()));
    }
  }

  /// Categorize packages by type: Center (id: 2) and Home (id: 3)
  ({List<PackageEntity> centerPackages, List<PackageEntity> homePackages})
      _categorizePackages(List<PackageEntity> packages) {
    final centerPackages = <PackageEntity>[];
    final homePackages = <PackageEntity>[];

    for (final package in packages) {
      if (package.packageTypeId == 2) {
        // Center
        centerPackages.add(package);
      } else if (package.packageTypeId == 3) {
        // Home
        homePackages.add(package);
      }
    }

    return (
      centerPackages: centerPackages,
      homePackages: homePackages,
    );
  }

  void _onFilterChanged(
    PackageFilterChanged event,
    Emitter<PackageState> emit,
  ) {
    final currentState = state;
    if (currentState is PackageLoaded) {
      emit(currentState.copyWith(currentFilter: event.filter));
    }
  }
}
