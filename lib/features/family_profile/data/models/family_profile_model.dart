import 'package:equatable/equatable.dart';
import '../../domain/entities/family_profile_entity.dart';

/// Family profile model
class FamilyProfileModel extends Equatable {
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

  const FamilyProfileModel({
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

  factory FamilyProfileModel.fromJson(Map<String, dynamic> json) =>
      FamilyProfileModel(
        id: json['id'] as int,
        memberTypeId: json['memberTypeId'] as int?,
        customerId: json['customerId'] as String,
        fullName: json['fullName'] as String,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'] as String)
            : null,
        gender: json['gender'] as String?,
        address: json['address'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        isOwner: json['isOwner'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberTypeId': memberTypeId,
        'customerId': customerId,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'address': address,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isOwner': isOwner,
      };

  FamilyProfileEntity toEntity() => FamilyProfileEntity(
        id: id,
        memberTypeId: memberTypeId,
        customerId: customerId,
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isOwner: isOwner,
      );

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
