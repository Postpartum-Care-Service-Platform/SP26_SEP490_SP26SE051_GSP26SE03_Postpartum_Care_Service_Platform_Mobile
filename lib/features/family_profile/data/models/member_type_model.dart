import 'package:equatable/equatable.dart';

/// Member type model
class MemberTypeModel extends Equatable {
  final int id;
  final String name;
  final bool isActive;
  final int? roleId;
  final String? roleName;

  const MemberTypeModel({
    required this.id,
    required this.name,
    required this.isActive,
    this.roleId,
    this.roleName,
  });

  factory MemberTypeModel.fromJson(Map<String, dynamic> json) =>
      MemberTypeModel(
        id: json['id'] as int? ?? json['Id'] as int,
        name: (json['name'] ?? json['Name'] ?? '').toString(),
        isActive: json['isActive'] as bool? ?? json['IsActive'] as bool? ?? true,
        roleId: json['roleId'] as int? ?? json['RoleId'] as int?,
        roleName: json['roleName'] as String? ?? json['RoleName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isActive': isActive,
        if (roleId != null) 'roleId': roleId,
        if (roleName != null) 'roleName': roleName,
      };

  @override
  List<Object?> get props => [id, name, isActive, roleId, roleName];
}
