import 'package:equatable/equatable.dart';

/// Change password response model
class ChangePasswordResponseModel extends Equatable {
  final String message;

  const ChangePasswordResponseModel({
    required this.message,
  });

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) =>
      ChangePasswordResponseModel(
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
      };

  @override
  List<Object?> get props => [message];
}
