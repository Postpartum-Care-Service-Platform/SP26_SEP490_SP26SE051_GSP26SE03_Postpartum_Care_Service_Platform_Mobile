import 'package:equatable/equatable.dart';

/// Package events
abstract class PackageEvent extends Equatable {
  const PackageEvent();

  @override
  List<Object?> get props => [];
}

/// Load packages event
class PackageLoadRequested extends PackageEvent {
  const PackageLoadRequested();
}

/// Refresh packages event
class PackageRefresh extends PackageEvent {
  const PackageRefresh();
}
