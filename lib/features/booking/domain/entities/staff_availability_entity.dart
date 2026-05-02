import 'package:equatable/equatable.dart';

class StaffAvailabilityEntity extends Equatable {
  final bool hasAvailableStaff;
  final int availableCount;
  final int totalCount;
  final String from;
  final String to;

  const StaffAvailabilityEntity({
    required this.hasAvailableStaff,
    required this.availableCount,
    required this.totalCount,
    required this.from,
    required this.to,
  });

  @override
  List<Object?> get props => [hasAvailableStaff, availableCount, totalCount, from, to];
}
