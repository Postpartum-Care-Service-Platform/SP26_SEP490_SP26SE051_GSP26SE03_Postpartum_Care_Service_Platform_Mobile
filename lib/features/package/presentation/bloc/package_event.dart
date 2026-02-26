import 'package:equatable/equatable.dart';

/// Package filter enum
enum PackageFilter {
  center,
  home,
}

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

/// Filter packages by type event
class PackageFilterChanged extends PackageEvent {
  final PackageFilter filter;

  const PackageFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}