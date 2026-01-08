import 'package:equatable/equatable.dart';

/// User entity
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
  });

  @override
  List<Object?> get props => [id, email, username, role];
}

