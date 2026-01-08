import 'package:equatable/equatable.dart';

/// Register request model
class RegisterRequestModel extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String username;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'phone': phone,
        'username': username,
      };

  @override
  List<Object?> get props => [email, password, confirmPassword, phone, username];
}

