import 'package:equatable/equatable.dart';

/// Forgot password request model
class ForgotPasswordRequestModel extends Equatable {
  final String email;

  const ForgotPasswordRequestModel({
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
      };

  @override
  List<Object?> get props => [email];
}