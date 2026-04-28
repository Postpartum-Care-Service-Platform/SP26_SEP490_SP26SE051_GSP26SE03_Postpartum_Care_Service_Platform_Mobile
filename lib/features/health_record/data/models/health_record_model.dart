import 'package:equatable/equatable.dart';
import '../../domain/entities/health_record_entity.dart';

class HealthConditionModel extends Equatable {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final String category;
  final String appliesTo;

  const HealthConditionModel({
    required this.id,
    required this.name,
    this.code,
    this.description,
    required this.category,
    required this.appliesTo,
  });

  factory HealthConditionModel.fromJson(Map<String, dynamic> json) {
    return HealthConditionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String,
      appliesTo: json['appliesTo'] as String,
    );
  }

  HealthConditionEntity toEntity() {
    return HealthConditionEntity(
      id: id,
      name: name,
      code: code,
      description: description,
      category: category,
      appliesTo: appliesTo,
    );
  }

  @override
  List<Object?> get props => [id, name, code, description, category, appliesTo];
}

class HealthRecordModel extends Equatable {
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
  final List<HealthConditionModel> conditions;

  const HealthRecordModel({
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

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: json['id'] as int,
      familyProfileId: json['familyProfileId'] as int,
      familyProfileName: json['familyProfileName'] as String,
      recordedBy: json['recordedBy'] as String?,
      recordedByName: json['recordedByName'] as String?,
      recordDate: DateTime.parse(json['recordDate'] as String),
      gestationalAgeWeeks: json['gestationalAgeWeeks'] as int?,
      birthWeightGrams: json['birthWeightGrams'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      generalCondition: json['generalCondition'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => HealthConditionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  HealthRecordEntity toEntity() {
    return HealthRecordEntity(
      id: id,
      familyProfileId: familyProfileId,
      familyProfileName: familyProfileName,
      recordedBy: recordedBy,
      recordedByName: recordedByName,
      recordDate: recordDate,
      gestationalAgeWeeks: gestationalAgeWeeks,
      birthWeightGrams: birthWeightGrams,
      weight: weight,
      height: height,
      temperature: temperature,
      generalCondition: generalCondition,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
      conditions: conditions.map((e) => e.toEntity()).toList(),
    );
  }

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
