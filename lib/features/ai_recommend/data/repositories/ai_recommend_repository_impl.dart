import '../../domain/entities/ai_recommendation_entity.dart';
import '../../domain/repositories/ai_recommend_repository.dart';
import '../datasources/ai_recommend_remote_datasource.dart';

class AiRecommendRepositoryImpl implements AiRecommendRepository {
  final AiRecommendRemoteDataSource remoteDataSource;

  AiRecommendRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AiRecommendation> recommendForFamily(List<int> familyProfileIds) {
    return remoteDataSource.recommendForFamily(familyProfileIds);
  }
}
