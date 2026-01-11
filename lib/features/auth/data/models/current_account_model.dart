import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

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
  });

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
      ];
}
