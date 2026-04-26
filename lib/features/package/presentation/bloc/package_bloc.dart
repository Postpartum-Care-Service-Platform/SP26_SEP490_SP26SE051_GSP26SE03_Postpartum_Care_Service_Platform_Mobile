import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/package_entity.dart';
import '../../domain/usecases/get_packages_usecase.dart';
import 'package_event.dart';
import 'package_state.dart';

/// Package BloC
class PackageBloc extends Bloc<PackageEvent, PackageState> {
  final GetPackagesUsecase getPackagesUsecase;
  final GetMyCustomPackagesUsecase getMyCustomPackagesUsecase;
 
   PackageBloc({
     required this.getPackagesUsecase,
     required this.getMyCustomPackagesUsecase,
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
      
      // Also fetch personalized if possible, or just start with empty
      List<PackageEntity> personalized = [];
      try {
        personalized = await getMyCustomPackagesUsecase();
      } catch (_) {
        // Silently fail or handle later
      }

      emit(PackageLoaded(
        centerPackages: categorized.centerPackages,
        homePackages: categorized.homePackages,
        personalizedPackages: personalized,
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
      
      List<PackageEntity> personalized = [];
      try {
        personalized = await getMyCustomPackagesUsecase();
      } catch (_) {}

      final currentState = state;
      if (currentState is PackageLoaded) {
        emit(PackageLoaded(
          centerPackages: categorized.centerPackages,
          homePackages: categorized.homePackages,
          personalizedPackages: personalized,
          currentFilter: currentState.currentFilter,
        ));
      } else {
        emit(PackageLoaded(
          centerPackages: categorized.centerPackages,
          homePackages: categorized.homePackages,
          personalizedPackages: personalized,
          currentFilter: PackageFilter.center,
        ));
      }
    } catch (e) {
      emit(PackageError(e.toString()));
    }
  }

  /// Categorize packages by type.
  ///
  /// Backend mới cho endpoint `/Packages/center` đang trả về packageTypeId = 1
  /// ("Trung tâm"). Vì vậy ưu tiên gom tất cả vào center và chỉ tách home khi
  /// nhận diện rõ là gói tại nhà.
  ({List<PackageEntity> centerPackages, List<PackageEntity> homePackages})
      _categorizePackages(List<PackageEntity> packages) {
    final centerPackages = <PackageEntity>[];
    final homePackages = <PackageEntity>[];

    for (final package in packages) {
      if (!package.isActive) continue;

      final packageTypeName = package.packageTypeName?.toLowerCase() ?? '';
      final isHome = package.packageTypeId == 3 || packageTypeName.contains('home');

      if (isHome) {
        homePackages.add(package);
      } else {
        // Mặc định xem là gói trung tâm (bao gồm packageTypeId == 1).
        centerPackages.add(package);
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
