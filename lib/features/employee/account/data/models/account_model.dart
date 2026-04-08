/// Owner profile gọn để mapping từ Account API cho UI staff.
class AccountOwnerProfileModel {
  final int id;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? memberTypeName;

  const AccountOwnerProfileModel({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.memberTypeName,
  });

  factory AccountOwnerProfileModel.fromJson(Map<String, dynamic> json) {
    return AccountOwnerProfileModel(
      id: json['id'] as int? ?? 0,
      fullName: (json['fullName'] as String?)?.trim() ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      memberTypeName: json['memberTypeName'] as String?,
    );
  }
}

/// Account Model for customer selection
class AccountModel {
  final String id;
  final int? roleId;
  final String email;
  final String? phone;
  final String? username;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String roleName;
  final bool isEmailVerified;
  final String? avatarUrl;
  final AccountOwnerProfileModel? ownerProfile;

  AccountModel({
    required this.id,
    this.roleId,
    required this.email,
    this.phone,
    this.username,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.roleName,
    required this.isEmailVerified,
    this.avatarUrl,
    this.ownerProfile,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      roleId: json['roleId'] as int?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      username: json['username'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      roleName: json['roleName'] as String? ?? 'customer',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      ownerProfile: json['ownerProfile'] is Map<String, dynamic>
          ? AccountOwnerProfileModel.fromJson(
              json['ownerProfile'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
              'fullName': ownerProfile!.fullName,
              'phoneNumber': ownerProfile!.phoneNumber,
              'avatarUrl': ownerProfile!.avatarUrl,
              'memberTypeName': ownerProfile!.memberTypeName,
            }
          : null,
    };
  }

  /// Get display name (ưu tiên ownerProfile.fullName, fallback username/email)
  String get displayName {
    final ownerName = ownerProfile?.fullName.trim();
    if (ownerName != null && ownerName.isNotEmpty) return ownerName;
    return username ?? email;
  }

  /// Check if is customer role
  bool get isCustomer => roleName.toLowerCase() == 'customer';
}
