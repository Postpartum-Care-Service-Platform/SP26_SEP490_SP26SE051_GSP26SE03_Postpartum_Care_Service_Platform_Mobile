import 'package:equatable/equatable.dart';

/// Register response model
class RegisterResponseModel extends Equatable {
  final String message;

  const RegisterResponseModel({
    required this.message,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterResponseModel(
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
      };

  @override
  List<Object?> get props => [message];
}

