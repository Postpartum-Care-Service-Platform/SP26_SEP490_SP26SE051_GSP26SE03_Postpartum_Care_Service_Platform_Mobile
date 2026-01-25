import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Owner profile model nested in CurrentAccountModel
class OwnerProfileModel extends Equatable {
  final int id;
  final int? memberTypeId;
  final String? memberTypeName;
  final String customerId;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isOwner;

  const OwnerProfileModel({
    required this.id,
    this.memberTypeId,
    this.memberTypeName,
    required this.customerId,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isOwner,
  });

  factory OwnerProfileModel.fromJson(Map<String, dynamic> json) =>
      OwnerProfileModel(
        id: json['id'] as int,
        memberTypeId: json['memberTypeId'] as int?,
        memberTypeName: json['memberTypeName'] as String?,
        customerId: json['customerId'] as String,
        fullName: json['fullName'] as String,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'] as String)
            : null,
        gender: json['gender'] as String?,
        address: json['address'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        isDeleted: json['isDeleted'] as bool? ?? false,
        isOwner: json['isOwner'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        id,
        memberTypeId,
        memberTypeName,
        customerId,
        fullName,
        dateOfBirth,
        gender,
        address,
        phoneNumber,
        avatarUrl,
        createdAt,
        updatedAt,
        isDeleted,
        isOwner,
      ];
}

/// Transaction info for the current package (nowPackage.nowTransactionResponses)
class NowTransactionResponseModel extends Equatable {
  final String transactionId;
  final double amount;
  final String type;
  final String transactionStatus;

  const NowTransactionResponseModel({
    required this.transactionId,
    required this.amount,
    required this.type,
    required this.transactionStatus,
  });

  factory NowTransactionResponseModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final parsedAmount = rawAmount is num ? rawAmount.toDouble() : 0.0;

    return NowTransactionResponseModel(
      transactionId: json['transactionId'] as String,
      amount: parsedAmount,
      type: json['type'] as String,
      transactionStatus: json['transactionStatus'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'transactionId': transactionId,
        'amount': amount,
        'type': type,
        'transactionStatus': transactionStatus,
      };

  @override
  List<Object?> get props => [
        transactionId,
        amount,
        type,
        transactionStatus,
      ];
}

/// Information about the customer's current/active package (nowPackage)
class NowPackageModel extends Equatable {
  final bool serviceIsActive;
  final int bookingId;
  final String bookingStatus;
  final double paidAmount;
  final double remainingAmount;
  final int packageId;
  final String packageName;
  final DateTime checkinDate;
  final DateTime checkoutDate;
  final int roomTypeId;
  final String roomTypeName;
  final String? roomName;
  final int? floor;
  final int contractId;
  final String contractCode;
  final String contractStatus;
  final List<NowTransactionResponseModel> nowTransactionResponses;

  const NowPackageModel({
    required this.serviceIsActive,
    required this.bookingId,
    required this.bookingStatus,
    required this.paidAmount,
    required this.remainingAmount,
    required this.packageId,
    required this.packageName,
    required this.checkinDate,
    required this.checkoutDate,
    required this.roomTypeId,
    required this.roomTypeName,
    this.roomName,
    this.floor,
    required this.contractId,
    required this.contractCode,
    required this.contractStatus,
    this.nowTransactionResponses = const [],
  });

  factory NowPackageModel.fromJson(Map<String, dynamic> json) {
    final rawPaidAmount = json['paidAmount'];
    final paidAmount = rawPaidAmount is num ? rawPaidAmount.toDouble() : 0.0;
    final rawRemainingAmount = json['remainingAmount'];
    final remainingAmount =
        rawRemainingAmount is num ? rawRemainingAmount.toDouble() : 0.0;

    return NowPackageModel(
      serviceIsActive: json['serviceIsActive'] as bool? ?? false,
      bookingId: json['bookingId'] as int,
      bookingStatus: json['bookingStatus'] as String,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      packageId: json['packageId'] as int,
      packageName: json['packageName'] as String,
      checkinDate: DateTime.parse(json['checkinDate'] as String),
      checkoutDate: DateTime.parse(json['checkoutDate'] as String),
      roomTypeId: json['roomTypeId'] as int,
      roomTypeName: json['roomTypeName'] as String,
      roomName: json['roomName'] as String?,
      floor: json['floor'] as int?,
      contractId: json['contractId'] as int,
      contractCode: json['contractCode'] as String,
      contractStatus: json['contractStatus'] as String,
      nowTransactionResponses: (json['nowTransactionResponses'] as List<dynamic>?)
              ?.map(
                (e) => NowTransactionResponseModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'serviceIsActive': serviceIsActive,
        'bookingId': bookingId,
        'bookingStatus': bookingStatus,
        'paidAmount': paidAmount,
        'remainingAmount': remainingAmount,
        'packageId': packageId,
        'packageName': packageName,
        'checkinDate': checkinDate.toIso8601String(),
        'checkoutDate': checkoutDate.toIso8601String(),
        'roomTypeId': roomTypeId,
        'roomTypeName': roomTypeName,
        'roomName': roomName,
        'floor': floor,
        'contractId': contractId,
        'contractCode': contractCode,
        'contractStatus': contractStatus,
        'nowTransactionResponses':
            nowTransactionResponses.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        serviceIsActive,
        bookingId,
        bookingStatus,
        paidAmount,
        remainingAmount,
        packageId,
        packageName,
        checkinDate,
        checkoutDate,
        roomTypeId,
        roomTypeName,
        roomName,
        floor,
        contractId,
        contractCode,
        contractStatus,
        nowTransactionResponses,
      ];
}

/// Current account model from GetCurrentAccount API
class CurrentAccountModel extends Equatable {
  final String id;
  final int roleId;
  final String email;
  final String phone;
  final String username;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String roleName;
  final bool isEmailVerified;
  final String? avatarUrl;
  final OwnerProfileModel? ownerProfile;
  final NowPackageModel? nowPackage;

  const CurrentAccountModel({
    required this.id,
    required this.roleId,
    required this.email,
    required this.phone,
    required this.username,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.roleName,
    required this.isEmailVerified,
    this.avatarUrl,
    this.ownerProfile,
    this.nowPackage,
  });

  /// Get display name - prefer fullName from ownerProfile, fallback to username
  String get displayName => ownerProfile?.fullName ?? username;

  factory CurrentAccountModel.fromJson(Map<String, dynamic> json) =>
      CurrentAccountModel(
        id: json['id'] as String,
        roleId: json['roleId'] as int,
        email: json['email'] as String,
        phone: json['phone'] as String,
        username: json['username'] as String,
        isActive: json['isActive'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        roleName: json['roleName'] as String,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        avatarUrl: json['avatarUrl'] as String?,
        ownerProfile: json['ownerProfile'] != null
            ? OwnerProfileModel.fromJson(
                json['ownerProfile'] as Map<String, dynamic>,
              )
            : null,
        nowPackage: json['nowPackage'] != null
            ? NowPackageModel.fromJson(
                json['nowPackage'] as Map<String, dynamic>,
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'roleId': roleId,
        'email': email,
        'phone': phone,
        'username': username,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'roleName': roleName,
        'isEmailVerified': isEmailVerified,
        'avatarUrl': avatarUrl,
        'ownerProfile': ownerProfile != null
            ? {
                'id': ownerProfile!.id,
                'memberTypeId': ownerProfile!.memberTypeId,
                'memberTypeName': ownerProfile!.memberTypeName,
                'customerId': ownerProfile!.customerId,
                'fullName': ownerProfile!.fullName,
                'dateOfBirth': ownerProfile!.dateOfBirth?.toIso8601String(),
                'gender': ownerProfile!.gender,
                'address': ownerProfile!.address,
                'phoneNumber': ownerProfile!.phoneNumber,
                'avatarUrl': ownerProfile!.avatarUrl,
                'createdAt': ownerProfile!.createdAt.toIso8601String(),
                'updatedAt': ownerProfile!.updatedAt.toIso8601String(),
                'isDeleted': ownerProfile!.isDeleted,
                'isOwner': ownerProfile!.isOwner,
              }
            : null,
        'nowPackage': nowPackage?.toJson(),
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        username: username,
        role: roleName,
      );

  @override
  List<Object?> get props => [
        id,
        roleId,
        email,
        phone,
        username,
        isActive,
        createdAt,
        updatedAt,
        roleName,
        isEmailVerified,
        avatarUrl,
        ownerProfile,
        nowPackage,
      ];
}
