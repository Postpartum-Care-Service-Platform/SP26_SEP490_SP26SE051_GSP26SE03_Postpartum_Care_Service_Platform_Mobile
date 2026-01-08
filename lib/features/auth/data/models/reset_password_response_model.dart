import 'package:equatable/equatable.dart';

/// Reset password response model
class ResetPasswordResponseModel extends Equatable {
  final String message;

  const ResetPasswordResponseModel({
    required this.message,
  });

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) =>
      ResetPasswordResponseModel(
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
      };

  @override
  List<Object?> get props => [message];
}