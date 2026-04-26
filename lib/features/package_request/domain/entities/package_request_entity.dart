import 'package:equatable/equatable.dart';

class PackageRequestFamilyProfile extends Equatable {
  final int id;
  final String fullName;
  final String memberType;

  final String? avatarUrl;
 
   const PackageRequestFamilyProfile({
     required this.id,
     required this.fullName,
     required this.memberType,
     this.avatarUrl,
   });

  @override
  List<Object?> get props => [id, fullName, memberType, avatarUrl];
}

class PackageRequestEntity extends Equatable {
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
  final List<PackageRequestFamilyProfile> familyProfiles;

  const PackageRequestEntity({
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

  PackageRequestEntity copyWith({
    int? id,
    String? customerId,
    String? customerName,
    int? basePackageId,
    String? basePackageName,
    String? basePackageImageUrl,
    int? packageId,
    String? packageName,
    String? title,
    String? description,
    String? requestedStartDate,
    int? totalDays,
    int? status,
    String? statusName,
    String? rejectReason,
    String? customerFeedback,
    String? draftedBy,
    String? draftedByName,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PackageRequestFamilyProfile>? familyProfiles,
  }) {
    return PackageRequestEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      basePackageId: basePackageId ?? this.basePackageId,
      basePackageName: basePackageName ?? this.basePackageName,
      basePackageImageUrl: basePackageImageUrl ?? this.basePackageImageUrl,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      title: title ?? this.title,
      description: description ?? this.description,
      requestedStartDate: requestedStartDate ?? this.requestedStartDate,
      totalDays: totalDays ?? this.totalDays,
      status: status ?? this.status,
      statusName: statusName ?? this.statusName,
      rejectReason: rejectReason ?? this.rejectReason,
      customerFeedback: customerFeedback ?? this.customerFeedback,
      draftedBy: draftedBy ?? this.draftedBy,
      draftedByName: draftedByName ?? this.draftedByName,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      familyProfiles: familyProfiles ?? this.familyProfiles,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        basePackageId,
        basePackageName,
        basePackageImageUrl,
        packageId,
        packageName,
        title,
        description,
        requestedStartDate,
        totalDays,
        status,
        statusName,
        rejectReason,
        customerFeedback,
        draftedBy,
        draftedByName,
        approvedAt,
        createdAt,
        updatedAt,
        familyProfiles,
      ];
}
