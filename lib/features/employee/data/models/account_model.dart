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
    };
  }

  /// Get display name (username or email)
  String get displayName => username ?? email;

  /// Check if is customer role
  bool get isCustomer => roleName.toLowerCase() == 'customer';
}
