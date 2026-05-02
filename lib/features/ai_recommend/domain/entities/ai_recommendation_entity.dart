import 'package:equatable/equatable.dart';

class AiRecommendedPackage extends Equatable {
  final int packageId;
  final String packageName;
  final int matchScore;
  final String narrative;
  final List<String> pros;
  final List<String> cautions;
  final List<String> missingFit;

  const AiRecommendedPackage({
    required this.packageId,
    required this.packageName,
    required this.matchScore,
    required this.narrative,
    required this.pros,
    required this.cautions,
    required this.missingFit,
  });

  @override
  List<Object?> get props => [packageId, packageName, matchScore, narrative, pros, cautions, missingFit];
}

class AiRecommendation extends Equatable {
  final String promptVersion;
  final bool isFallback;
  final String? fallbackReason;
  final List<AiRecommendedPackage> packages;

  const AiRecommendation({
    required this.promptVersion,
    required this.isFallback,
    this.fallbackReason,
    required this.packages,
  });

  @override
  List<Object?> get props => [promptVersion, isFallback, fallbackReason, packages];
}
