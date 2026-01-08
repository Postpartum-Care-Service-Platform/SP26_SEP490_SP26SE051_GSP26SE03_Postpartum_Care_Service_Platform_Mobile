import 'package:equatable/equatable.dart';

/// Login request model
class LoginRequestModel extends Equatable {
  final String emailOrUsername;
  final String password;

  const LoginRequestModel({
    required this.emailOrUsername,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'emailOrUsername': emailOrUsername,
        'password': password,
      };

  @override
  List<Object?> get props => [emailOrUsername, password];
}

