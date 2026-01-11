import 'package:equatable/equatable.dart';
import '../../domain/entities/package_entity.dart';

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
  final List<PackageEntity> packages;

  const PackageLoaded({
    required this.packages,
  });

  @override
  List<Object?> get props => [packages];

  PackageLoaded copyWith({
    List<PackageEntity>? packages,
  }) {
    return PackageLoaded(
      packages: packages ?? this.packages,
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
