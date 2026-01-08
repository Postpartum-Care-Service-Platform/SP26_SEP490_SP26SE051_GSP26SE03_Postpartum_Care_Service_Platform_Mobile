import 'package:equatable/equatable.dart';

/// Member type model
class MemberTypeModel extends Equatable {
  final int id;
  final String name;
  final bool isActive;

  const MemberTypeModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory MemberTypeModel.fromJson(Map<String, dynamic> json) =>
      MemberTypeModel(
        id: json['id'] as int,
        name: json['name'] as String,
        isActive: json['isActive'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isActive': isActive,
      };

  @override
  List<Object?> get props => [id, name, isActive];
}
