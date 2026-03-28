import '../../domain/entities/target_booking_entity.dart';

class TargetBookingModel {
  final int id;
  final int familyProfileId;
  final String fullName;
  final String? relationship;

  TargetBookingModel({
    required this.id,
    required this.familyProfileId,
    required this.fullName,
    this.relationship,
  });

  factory TargetBookingModel.fromJson(Map<String, dynamic> json) {
    return TargetBookingModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      familyProfileId: (json['familyProfileId'] as num?)?.toInt() ?? 0,
      fullName: (json['fullName'] as String?) ?? '',
      relationship: json['relationship'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyProfileId': familyProfileId,
      'fullName': fullName,
      'relationship': relationship,
    };
  }

  TargetBookingEntity toEntity() {
    return TargetBookingEntity(
      id: id,
      familyProfileId: familyProfileId,
      fullName: fullName,
      relationship: relationship,
    );
  }
}
