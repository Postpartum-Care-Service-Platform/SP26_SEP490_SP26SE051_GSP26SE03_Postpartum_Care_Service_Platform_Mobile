import 'package:equatable/equatable.dart';

/// Amenity Events
abstract class AmenityEvent extends Equatable {
  const AmenityEvent();

  @override
  List<Object?> get props => [];
}

/// Load amenity services
class AmenityServicesLoadRequested extends AmenityEvent {
  const AmenityServicesLoadRequested();
}

/// Load my tickets
class MyAmenityTicketsLoadRequested extends AmenityEvent {
  const MyAmenityTicketsLoadRequested();
}

/// Create ticket
class AmenityTicketCreateRequested extends AmenityEvent {
  final int amenityServiceId;
  final DateTime startTime;
  final DateTime endTime;

  const AmenityTicketCreateRequested({
    required this.amenityServiceId,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [amenityServiceId, startTime, endTime];
}

/// Refresh all data
class AmenityRefresh extends AmenityEvent {
  const AmenityRefresh();
}
