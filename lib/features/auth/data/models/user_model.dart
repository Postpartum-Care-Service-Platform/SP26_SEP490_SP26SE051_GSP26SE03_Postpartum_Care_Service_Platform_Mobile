import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// User model
class UserModel extends Equatable {
  final String id;
  final String email;
  final String username;
  final String role;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        role: json['role'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'role': role,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        username: username,
        role: role,
      );

  @override
  List<Object?> get props => [id, email, username, role];
}

