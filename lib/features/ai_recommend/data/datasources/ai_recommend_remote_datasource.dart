import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/ai_recommendation_model.dart';

abstract class AiRecommendRemoteDataSource {
  Future<AiRecommendationModel> recommendForFamily(List<int> familyProfileIds);
}

class AiRecommendRemoteDataSourceImpl implements AiRecommendRemoteDataSource {
  final Dio dio;

  AiRecommendRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<AiRecommendationModel> recommendForFamily(List<int> familyProfileIds) async {
    final response = await dio.post(
      ApiEndpoints.aiRecommendPackage,
      data: {
        'familyProfileIds': familyProfileIds,
      },
    );

    return AiRecommendationModel.fromJson(response.data as Map<String, dynamic>);
  }
}
