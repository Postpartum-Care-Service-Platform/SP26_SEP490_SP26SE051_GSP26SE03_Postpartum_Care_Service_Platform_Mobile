// lib/features/auth/domain/entities/user_role.dart

/// UserRole
/// - Role used for routing after successful login.
enum UserRole {
  family,
  employee,
}

extension UserRoleX on UserRole {
  String get key {
    switch (this) {
      case UserRole.family:
        return 'family';
      case UserRole.employee:
        return 'employee';
    }
  }
}
