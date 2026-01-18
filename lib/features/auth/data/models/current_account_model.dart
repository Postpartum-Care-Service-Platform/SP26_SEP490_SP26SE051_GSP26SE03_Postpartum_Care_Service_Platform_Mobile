import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Owner profile model nested in CurrentAccountModel
class OwnerProfileModel extends Equatable {
  final int id;
  final int? memberTypeId;
  final String? memberTypeName;
  final String customerId;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isOwner;

  const OwnerProfileModel({
    required this.id,
    this.memberTypeId,
    this.memberTypeName,
    required this.customerId,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isOwner,
  });

  factory OwnerProfileModel.fromJson(Map<String, dynamic> json) =>
      OwnerProfileModel(
        id: json['id'] as int,
        memberTypeId: json['memberTypeId'] as int?,
        memberTypeName: json['memberTypeName'] as String?,
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
        isDeleted: json['isDeleted'] as bool? ?? false,
        isOwner: json['isOwner'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        id,
        memberTypeId,
        memberTypeName,
        customerId,
        fullName,
        dateOfBirth,
        gender,
        address,
        phoneNumber,
        avatarUrl,
        createdAt,
        updatedAt,
        isDeleted,
        isOwner,
      ];
}

/// Current account model from GetCurrentAccount API
class CurrentAccountModel extends Equatable {
  final String id;
  final int roleId;
  final String email;
  final String phone;
  final String username;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String roleName;
  final bool isEmailVerified;
  final String? avatarUrl;
  final OwnerProfileModel? ownerProfile;

  const CurrentAccountModel({
    required this.id,
    required this.roleId,
    required this.email,
    required this.phone,
    required this.username,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.roleName,
    required this.isEmailVerified,
    this.avatarUrl,
    this.ownerProfile,
  });

  /// Get display name - prefer fullName from ownerProfile, fallback to username
  String get displayName => ownerProfile?.fullName ?? username;

  factory CurrentAccountModel.fromJson(Map<String, dynamic> json) =>
      CurrentAccountModel(
        id: json['id'] as String,
        roleId: json['roleId'] as int,
        email: json['email'] as String,
        phone: json['phone'] as String,
        username: json['username'] as String,
        isActive: json['isActive'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        roleName: json['roleName'] as String,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        avatarUrl: json['avatarUrl'] as String?,
        ownerProfile: json['ownerProfile'] != null
            ? OwnerProfileModel.fromJson(
                json['ownerProfile'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'roleId': roleId,
        'email': email,
        'phone': phone,
        'username': username,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'roleName': roleName,
        'isEmailVerified': isEmailVerified,
        'avatarUrl': avatarUrl,
        'ownerProfile': ownerProfile != null
            ? {
                'id': ownerProfile!.id,
                'memberTypeId': ownerProfile!.memberTypeId,
                'memberTypeName': ownerProfile!.memberTypeName,
                'customerId': ownerProfile!.customerId,
                'fullName': ownerProfile!.fullName,
                'dateOfBirth': ownerProfile!.dateOfBirth?.toIso8601String(),
                'gender': ownerProfile!.gender,
                'address': ownerProfile!.address,
                'phoneNumber': ownerProfile!.phoneNumber,
                'avatarUrl': ownerProfile!.avatarUrl,
                'createdAt': ownerProfile!.createdAt.toIso8601String(),
                'updatedAt': ownerProfile!.updatedAt.toIso8601String(),
                'isDeleted': ownerProfile!.isDeleted,
                'isOwner': ownerProfile!.isOwner,
              }
            : null,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        username: username,
        role: roleName,
      );

  @override
  List<Object?> get props => [
        id,
        roleId,
        email,
        phone,
        username,
        isActive,
        createdAt,
        updatedAt,
        roleName,
        isEmailVerified,
        avatarUrl,
        ownerProfile,
      ];
}
