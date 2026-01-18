import '../../domain/entities/customer_entity.dart';

/// Customer Model - Data layer
class CustomerModel {
  final String id;
  final String email;
  final String username;
  final String phone;

  CustomerModel({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
    };
  }

  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      email: email,
      username: username,
      phone: phone,
    );
  }
}
