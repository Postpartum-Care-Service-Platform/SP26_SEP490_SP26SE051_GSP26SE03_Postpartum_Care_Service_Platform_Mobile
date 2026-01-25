import '../../domain/entities/customer_entity.dart';

/// Customer Model - Data layer
class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.email,
    required super.username,
    super.phone,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
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
      'phone': phone,
    };
  }
}
