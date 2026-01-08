import 'package:equatable/equatable.dart';

/// Family profile entity
class FamilyProfileEntity extends Equatable {
  final int id;
  final int? memberTypeId;
  final String customerId;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOwner;

  const FamilyProfileEntity({
    required this.id,
    this.memberTypeId,
    required this.customerId,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isOwner,
  });

  @override
  List<Object?> get props => [
        id,
        memberTypeId,
        customerId,
        fullName,
        dateOfBirth,
        gender,
        address,
        phoneNumber,
        avatarUrl,
        createdAt,
        updatedAt,
        isOwner,
      ];
}
