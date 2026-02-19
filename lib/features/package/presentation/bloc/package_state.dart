import 'package:equatable/equatable.dart';
import '../../domain/entities/package_entity.dart';
import 'package_event.dart';

/// Package states
abstract class PackageState extends Equatable {
  const PackageState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PackageInitial extends PackageState {
  const PackageInitial();
}

/// Loading state
class PackageLoading extends PackageState {
  const PackageLoading();
}

/// Loaded state
class PackageLoaded extends PackageState {
  final List<PackageEntity> centerPackages;
  final List<PackageEntity> homePackages;
  final PackageFilter currentFilter;

  const PackageLoaded({
    required this.centerPackages,
    required this.homePackages,
    this.currentFilter = PackageFilter.center,
  });

  List<PackageEntity> get allPackages => [...centerPackages, ...homePackages];
  
  List<PackageEntity> get filteredPackages {
    switch (currentFilter) {
      case PackageFilter.center:
        return centerPackages;
      case PackageFilter.home:
        return homePackages;
    }
  }

  @override
  List<Object?> get props => [centerPackages, homePackages, currentFilter];

  PackageLoaded copyWith({
    List<PackageEntity>? centerPackages,
    List<PackageEntity>? homePackages,
    PackageFilter? currentFilter,
  }) {
    return PackageLoaded(
      centerPackages: centerPackages ?? this.centerPackages,
      homePackages: homePackages ?? this.homePackages,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

/// Error state
class PackageError extends PackageState {
  final String message;

  const PackageError(this.message);

  @override
  List<Object?> get props => [message];
}
