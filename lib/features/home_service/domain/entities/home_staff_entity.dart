import 'package:equatable/equatable.dart';

/// Home Staff Entity - Domain layer
class HomeStaffEntity extends Equatable {
  final String id;
  final int roleId;
  final String roleName;
  final String email;
  final String phone;
  final String username;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final String? avatarUrl;
  final HomeStaffOwnerProfile? ownerProfile;

  const HomeStaffEntity({
    required this.id,
    required this.roleId,
    required this.roleName,
    required this.email,
    required this.phone,
    required this.username,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.isEmailVerified,
    this.avatarUrl,
    this.ownerProfile,
  });

  String? get fullName => ownerProfile?.fullName;
  DateTime? get dateOfBirth => ownerProfile?.dateOfBirth;
  
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  @override
  List<Object?> get props => [
        id,
        roleId,
        roleName,
        email,
        phone,
        username,
        isActive,
        createdAt,
        updatedAt,
        isEmailVerified,
        avatarUrl,
        ownerProfile,
      ];
}

/// Home Staff Owner Profile
class HomeStaffOwnerProfile extends Equatable {
  final int id;
  final int memberTypeId;
  final String? memberTypeName;
  final String customerId;
  final String fullName;
  final DateTime dateOfBirth;
  final String gender;
  final String address;
  final String phoneNumber;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isOwner;

  const HomeStaffOwnerProfile({
    required this.id,
    required this.memberTypeId,
    this.memberTypeName,
    required this.customerId,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isOwner,
  });

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
