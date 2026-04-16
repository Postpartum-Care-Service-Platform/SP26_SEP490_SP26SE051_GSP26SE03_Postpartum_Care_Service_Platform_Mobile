import 'package:equatable/equatable.dart';

/// Staff Entity - Domain layer
/// Represents a staff member assigned to a booking
class StaffEntity extends Equatable {
  final String id;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String? email;

  const StaffEntity({
    required this.id,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.email,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        avatarUrl,
        email,
      ];
}
