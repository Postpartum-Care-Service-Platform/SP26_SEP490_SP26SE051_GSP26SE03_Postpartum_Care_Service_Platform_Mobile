class CreateHealthRecordRequest {
  final int id;
  final int familyProfileId;
  final String familyProfileName;
  final String? recordedBy;
  final String? recordedByName;
  final String recordDate;
  final int? gestationalAgeWeeks;
  final int? birthWeightGrams;
  final double? weight;
  final double? height;
  final double? temperature;
  final String? generalCondition;
  final String? note;
  final String createdAt;
  final String updatedAt;
  final List<int>? conditionIds;

  CreateHealthRecordRequest({
    this.id = 0,
    required this.familyProfileId,
    this.familyProfileName = '',
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
    this.createdAt = '',
    this.updatedAt = '',
    this.conditionIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'recordDate': recordDate.split('T').first,
      'gestationalAgeWeeks': gestationalAgeWeeks ?? 0,
      'birthWeightGrams': birthWeightGrams ?? 0,
      'weight': weight ?? 0.0,
      'height': height ?? 0.0,
      'temperature': temperature ?? 0.0,
      'generalCondition': generalCondition ?? '',
      'note': note ?? '',
      'conditionIds': conditionIds ?? [],
    };
  }
}
