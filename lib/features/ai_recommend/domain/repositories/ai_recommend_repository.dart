import '../entities/ai_recommendation_entity.dart';

abstract class AiRecommendRepository {
  Future<AiRecommendation> recommendForFamily(List<int> familyProfileIds);
}
