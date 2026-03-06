import 'package:equatable/equatable.dart';
import 'home_activity_entity.dart';

/// Home Service Selection Entity - Domain layer
/// Represents a selected activity with its dates and times
class HomeServiceSelectionEntity extends Equatable {
  final HomeActivityEntity activity;
  final Map<DateTime, ServiceTimeSlot> dateTimeSlots; // date -> time slot

  const HomeServiceSelectionEntity({
    required this.activity,
    required this.dateTimeSlots,
  });

  List<DateTime> get selectedDates => dateTimeSlots.keys.toList()..sort();

  @override
  List<Object?> get props => [activity, dateTimeSlots];
}

/// Service Time Slot
class ServiceTimeSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;

  const ServiceTimeSlot({
    required this.startTime,
    required this.endTime,
  });

  String get startTimeString {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get endTimeString {
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  String get timeRange => '$startTimeString - $endTimeString';

  @override
  List<Object?> get props => [startTime, endTime];
}
