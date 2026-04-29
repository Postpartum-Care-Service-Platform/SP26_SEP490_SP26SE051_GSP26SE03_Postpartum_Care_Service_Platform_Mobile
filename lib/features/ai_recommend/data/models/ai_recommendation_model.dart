import '../../domain/entities/ai_recommendation_entity.dart';

class AiRecommendedPackageModel extends AiRecommendedPackage {
  const AiRecommendedPackageModel({
    required super.packageId,
    required super.packageName,
    required super.matchScore,
    required super.narrative,
    required super.pros,
    required super.cautions,
    required super.missingFit,
  });

  factory AiRecommendedPackageModel.fromJson(Map<String, dynamic> json) {
    return AiRecommendedPackageModel(
      packageId: json['packageId'] as int,
      packageName: json['packageName'] as String,
      matchScore: json['matchScore'] as int,
      narrative: json['narrative'] as String,
      pros: (json['pros'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      cautions: (json['cautions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      missingFit: (json['missingFit'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class AiRecommendationModel extends AiRecommendation {
  const AiRecommendationModel({
    required super.promptVersion,
    required super.isFallback,
    super.fallbackReason,
    required super.packages,
  });

  factory AiRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AiRecommendationModel(
      promptVersion: json['promptVersion'] as String? ?? '',
      isFallback: json['isFallback'] as bool? ?? false,
      fallbackReason: json['fallbackReason'] as String?,
      packages: (json['packages'] as List<dynamic>?)
              ?.map((e) => AiRecommendedPackageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
