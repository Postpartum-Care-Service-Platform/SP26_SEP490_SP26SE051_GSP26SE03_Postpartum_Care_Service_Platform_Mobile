import 'package:equatable/equatable.dart';

/// User entity
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String role;
  final String? memberType;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    this.memberType,
  });

  @override
  List<Object?> get props => [id, email, username, role, memberType];
}

