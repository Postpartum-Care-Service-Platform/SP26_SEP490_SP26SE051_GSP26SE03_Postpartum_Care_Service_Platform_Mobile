import '../../domain/entities/home_staff_entity.dart';

/// Home Staff Model - Data layer
class HomeStaffModel extends HomeStaffEntity {
  const HomeStaffModel({
    required super.id,
    required super.roleId,
    required super.roleName,
    required super.email,
    required super.phone,
    required super.username,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.isEmailVerified,
    super.avatarUrl,
    super.ownerProfile,
  });

  factory HomeStaffModel.fromJson(Map<String, dynamic> json) {
    return HomeStaffModel(
      id: json['id'] as String,
      roleId: json['roleId'] as int,
      roleName: json['roleName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      username: json['username'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isEmailVerified: json['isEmailVerified'] as bool,
      avatarUrl: json['avatarUrl'] as String?,
      ownerProfile: json['ownerProfile'] != null
          ? HomeStaffOwnerProfileModel.fromJson(
              json['ownerProfile'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'roleName': roleName,
      'email': email,
      'phone': phone,
      'username': username,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'avatarUrl': avatarUrl,
      'ownerProfile': ownerProfile != null
          ? (ownerProfile as HomeStaffOwnerProfileModel).toJson()
          : null,
    };
  }

  HomeStaffEntity toEntity() {
    return HomeStaffEntity(
      id: id,
      roleId: roleId,
      roleName: roleName,
      email: email,
      phone: phone,
      username: username,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEmailVerified: isEmailVerified,
      avatarUrl: avatarUrl,
      ownerProfile: ownerProfile,
    );
  }
}

/// Home Staff Owner Profile Model
class HomeStaffOwnerProfileModel extends HomeStaffOwnerProfile {
  const HomeStaffOwnerProfileModel({
    required super.id,
    required super.memberTypeId,
    super.memberTypeName,
    required super.customerId,
    required super.fullName,
    required super.dateOfBirth,
    required super.gender,
    required super.address,
    required super.phoneNumber,
    super.avatarUrl,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    required super.isOwner,
  });

  factory HomeStaffOwnerProfileModel.fromJson(Map<String, dynamic> json) {
    return HomeStaffOwnerProfileModel(
      id: json['id'] as int,
      memberTypeId: json['memberTypeId'] as int,
      memberTypeName: json['memberTypeName'] as String?,
      customerId: (json['customerId'] ?? json['accountId'] ?? '') as String,
      fullName: (json['fullName'] ?? '') as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool,
      isOwner: json['isOwner'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberTypeId': memberTypeId,
      'memberTypeName': memberTypeName,
      'customerId': customerId,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'isOwner': isOwner,
    };
  }
}
