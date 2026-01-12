import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_entity.dart';

/// User info model - Data layer
class UserInfoModel extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? phone;

  const UserInfoModel({
    required this.id,
    required this.email,
    required this.username,
    this.phone,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      if (phone != null) 'phone': phone,
    };
  }

  UserInfoEntity toEntity() {
    return UserInfoEntity(
      id: id,
      email: email,
      username: username,
      phone: phone,
    );
  }

  @override
  List<Object?> get props => [id, email, username, phone];
}
