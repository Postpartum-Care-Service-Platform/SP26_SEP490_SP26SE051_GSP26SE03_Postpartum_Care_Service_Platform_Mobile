import 'package:equatable/equatable.dart';

/// Customer Entity - Domain layer
class CustomerEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? phone;

  const CustomerEntity({
    required this.id,
    required this.email,
    required this.username,
    this.phone,
  });

  @override
  List<Object?> get props => [id, email, username, phone];
}
