import '../../domain/entities/package_request_entity.dart';

class PackageRequestFamilyProfileModel {
  final int id;
  final String fullName;
  final String memberType;

  final String? avatarUrl;
 
   PackageRequestFamilyProfileModel({
     required this.id,
     required this.fullName,
     required this.memberType,
     this.avatarUrl,
   });

  factory PackageRequestFamilyProfileModel.fromJson(Map<String, dynamic> json) {
    return PackageRequestFamilyProfileModel(
      id: json['id'] as int,
      fullName: json['fullName'] as String? ?? '',
      memberType: json['memberType'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  PackageRequestFamilyProfile toEntity() {
    return PackageRequestFamilyProfile(
      id: id,
      fullName: fullName,
      memberType: memberType,
      avatarUrl: avatarUrl,
    );
  }
}

class PackageRequestModel {
  final int id;
  final String customerId;
  final String customerName;
  final int basePackageId;
  final String basePackageName;
  final String? basePackageImageUrl;
  final int? packageId;
  final String? packageName;
  final String title;
  final String description;
  final String requestedStartDate;
  final int totalDays;
  final int status;
  final String statusName;
  final String? rejectReason;
  final String? customerFeedback;
  final String? draftedBy;
  final String? draftedByName;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PackageRequestFamilyProfileModel> familyProfiles;

  PackageRequestModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.basePackageId,
    required this.basePackageName,
    this.basePackageImageUrl,
    this.packageId,
    this.packageName,
    required this.title,
    required this.description,
    required this.requestedStartDate,
    required this.totalDays,
    required this.status,
    required this.statusName,
    this.rejectReason,
    this.customerFeedback,
    this.draftedBy,
    this.draftedByName,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.familyProfiles,
  });

  factory PackageRequestModel.fromJson(Map<String, dynamic> json) {
    return PackageRequestModel(
      id: json['id'] as int,
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      basePackageId: json['basePackageId'] as int? ?? 0,
      basePackageName: json['basePackageName'] as String? ?? '',
      basePackageImageUrl: json['basePackageImageUrl'] as String?,
      packageId: json['packageId'] as int?,
      packageName: json['packageName'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requestedStartDate: json['requestedStartDate'] as String? ?? '',
      totalDays: json['totalDays'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      statusName: json['statusName'] as String? ?? 'Pending',
      rejectReason: json['rejectReason'] as String?,
      customerFeedback: json['customerFeedback'] as String?,
      draftedBy: json['draftedBy'] as String?,
      draftedByName: json['draftedByName'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      familyProfiles: (json['familyProfiles'] as List<dynamic>?)
              ?.map((e) => PackageRequestFamilyProfileModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  PackageRequestEntity toEntity() {
    return PackageRequestEntity(
      id: id,
      customerId: customerId,
      customerName: customerName,
      basePackageId: basePackageId,
      basePackageName: basePackageName,
      basePackageImageUrl: basePackageImageUrl,
      packageId: packageId,
      packageName: packageName,
      title: title,
      description: description,
      requestedStartDate: requestedStartDate,
      totalDays: totalDays,
      status: status,
      statusName: statusName,
      rejectReason: rejectReason,
      customerFeedback: customerFeedback,
      draftedBy: draftedBy,
      draftedByName: draftedByName,
      approvedAt: approvedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      familyProfiles: familyProfiles.map((e) => e.toEntity()).toList(),
    );
  }
}
