import 'package:equatable/equatable.dart';

class HealthConditionEntity extends Equatable {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final String category;
  final String? appliesTo;
  final int? memberTypeId;
  final String? memberTypeName;

  const HealthConditionEntity({
    required this.id,
    required this.name,
    this.code,
    this.description,
    required this.category,
    this.appliesTo,
    this.memberTypeId,
    this.memberTypeName,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        description,
        category,
        appliesTo,
        memberTypeId,
        memberTypeName,
      ];
}

class HealthRecordEntity extends Equatable {
  final int id;
  final int familyProfileId;
  final String familyProfileName;
  final String? recordedBy;
  final String? recordedByName;
  final DateTime recordDate;
  final int? gestationalAgeWeeks;
  final int? birthWeightGrams;
  final double? weight;
  final double? height;
  final double? temperature;
  final String? generalCondition;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<HealthConditionEntity> conditions;

  const HealthRecordEntity({
    required this.id,
    required this.familyProfileId,
    required this.familyProfileName,
    this.recordedBy,
    this.recordedByName,
    required this.recordDate,
    this.gestationalAgeWeeks,
    this.birthWeightGrams,
    this.weight,
    this.height,
    this.temperature,
    this.generalCondition,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.conditions = const [],
  });

  @override
  List<Object?> get props => [
        id,
        familyProfileId,
        familyProfileName,
        recordedBy,
        recordedByName,
        recordDate,
        gestationalAgeWeeks,
        birthWeightGrams,
        weight,
        height,
        temperature,
        generalCondition,
        note,
        createdAt,
        updatedAt,
        conditions,
      ];
}
