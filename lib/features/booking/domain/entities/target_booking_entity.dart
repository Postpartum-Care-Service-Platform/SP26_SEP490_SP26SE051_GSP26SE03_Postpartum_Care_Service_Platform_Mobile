import 'package:equatable/equatable.dart';

/// Target Booking Entity - person/profile included in a booking
class TargetBookingEntity extends Equatable {
  final int id;
  final int familyProfileId;
  final String fullName;
  final String? relationship;

  const TargetBookingEntity({
    required this.id,
    required this.familyProfileId,
    required this.fullName,
    this.relationship,
  });

  @override
  List<Object?> get props => [
        id,
        familyProfileId,
        fullName,
        relationship,
      ];
}
