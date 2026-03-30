import 'package:equatable/equatable.dart';
import '../../domain/entities/package_entity.dart';
import '../../../care_plan/data/models/care_plan_model.dart';

/// Package model - Data layer
class PackageModel extends Equatable {
  final int id;
  final String packageName;
  final String description;
  final int? packageTypeId;
  final String? packageTypeName;
  final String? imageUrl;
  final int? roomTypeId;
  final String? roomTypeName;
  final int? durationDays;
  final double basePrice;
  final bool isActive;
  final String? createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasRoomAvailabilityWarning;
  final DateTime? unavailableFrom;
  final DateTime? unavailableTo;
  final DateTime? firstAvailableDate;
  final int? totalRooms;
  final int? availableRooms;
  final List<CarePlanModel>? carePlanDetails;

  const PackageModel({
    required this.id,
    required this.packageName,
    required this.description,
    this.packageTypeId,
    this.packageTypeName,
    this.imageUrl,
    this.roomTypeId,
    this.roomTypeName,
    this.durationDays,
    required this.basePrice,
    required this.isActive,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.hasRoomAvailabilityWarning = false,
    this.unavailableFrom,
    this.unavailableTo,
    this.firstAvailableDate,
    this.totalRooms,
    this.availableRooms,
    this.carePlanDetails,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
  return PackageModel(
    id: json['id'] as int,
    // Sửa description: cho phép null hoặc để mặc định là chuỗi rỗng
    packageName: json['packageName']?.toString() ?? '', 
    description: json['description']?.toString() ?? '', // Tránh lỗi null string
    
    packageTypeId: json['packageTypeId'] as int?,
    packageTypeName: json['packageTypeName'] as String?,
    imageUrl: json['imageUrl'] as String?,
    roomTypeId: json['roomTypeId'] as int?,
    roomTypeName: json['roomTypeName'] as String?,
    durationDays: json['durationDays'] as int?,
    
    // Sử dụng num để an toàn cho cả int và double từ API
    basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
    isActive: json['isActive'] as bool? ?? false,
    
    createdBy: json['createdBy'] as String?,
    createdByName: json['createdByName'] as String?,
    
    // DateTime.parse cần kiểm tra null trước khi gọi
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String) 
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'] as String) 
        : DateTime.now(),
        
    hasRoomAvailabilityWarning: json['hasRoomAvailabilityWarning'] as bool? ?? false,
    unavailableFrom: json['unavailableFrom'] != null
        ? DateTime.parse(json['unavailableFrom'] as String)
        : null,
    unavailableTo: json['unavailableTo'] != null
        ? DateTime.parse(json['unavailableTo'] as String)
        : null,
    firstAvailableDate: json['firstAvailableDate'] != null
        ? DateTime.parse(json['firstAvailableDate'] as String)
        : null,
    totalRooms: json['totalRooms'] as int?,
    availableRooms: json['availableRooms'] as int?,
    carePlanDetails: json['carePlanDetails'] != null
        ? (json['carePlanDetails'] as List<dynamic>)
            .map((item) => CarePlanModel.fromJson(item as Map<String, dynamic>))
            .toList()
        : null,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageName': packageName,
      'description': description,
      'packageTypeId': packageTypeId,
      'packageTypeName': packageTypeName,
      'imageUrl': imageUrl,
      'roomTypeId': roomTypeId,
      'roomTypeName': roomTypeName,
      'durationDays': durationDays,
      'basePrice': basePrice,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'hasRoomAvailabilityWarning': hasRoomAvailabilityWarning,
      'unavailableFrom': unavailableFrom?.toIso8601String(),
      'unavailableTo': unavailableTo?.toIso8601String(),
      'firstAvailableDate': firstAvailableDate?.toIso8601String(),
      'totalRooms': totalRooms,
      'availableRooms': availableRooms,
      'carePlanDetails': carePlanDetails?.map((e) => e.toJson()).toList(),
    };
  }

  PackageEntity toEntity() {
    return PackageEntity(
      id: id,
      packageName: packageName,
      description: description,
      packageTypeId: packageTypeId,
      packageTypeName: packageTypeName,
      imageUrl: imageUrl,
      roomTypeId: roomTypeId,
      roomTypeName: roomTypeName,
      durationDays: durationDays,
      basePrice: basePrice,
      isActive: isActive,
      createdBy: createdBy,
      createdByName: createdByName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      hasRoomAvailabilityWarning: hasRoomAvailabilityWarning,
      unavailableFrom: unavailableFrom,
      unavailableTo: unavailableTo,
      firstAvailableDate: firstAvailableDate,
      totalRooms: totalRooms,
      availableRooms: availableRooms,
      carePlanDetails: carePlanDetails?.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        packageName,
        description,
        packageTypeId,
        packageTypeName,
        imageUrl,
        roomTypeId,
        roomTypeName,
        durationDays,
        basePrice,
        isActive,
        createdBy,
        createdByName,
        createdAt,
        updatedAt,
        hasRoomAvailabilityWarning,
        unavailableFrom,
        unavailableTo,
        firstAvailableDate,
        totalRooms,
        availableRooms,
        carePlanDetails,
      ];
}
