import 'package:equatable/equatable.dart';

/// Forgot password response model
class ForgotPasswordResponseModel extends Equatable {
  final String message;

  const ForgotPasswordResponseModel({
    required this.message,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResponseModel(
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
      };

  @override
  List<Object?> get props => [message];
}