import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_availability_entity.dart';

class StaffAvailabilityModel extends Equatable {
  final bool hasAvailableStaff;
  final int availableCount;
  final int totalCount;
  final String from;
  final String to;

  const StaffAvailabilityModel({
    required this.hasAvailableStaff,
    required this.availableCount,
    required this.totalCount,
    required this.from,
    required this.to,
  });

  StaffAvailabilityEntity toEntity() {
    return StaffAvailabilityEntity(
      hasAvailableStaff: hasAvailableStaff,
      availableCount: availableCount,
      totalCount: totalCount,
      from: from,
      to: to,
    );
  }

  factory StaffAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return StaffAvailabilityModel(
      hasAvailableStaff: json['hasAvailableStaff'] ?? false,
      availableCount: json['availableCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasAvailableStaff': hasAvailableStaff,
      'availableCount': availableCount,
      'totalCount': totalCount,
      'from': from,
      'to': to,
    };
  }

  @override
  List<Object?> get props => [hasAvailableStaff, availableCount, totalCount, from, to];
}
