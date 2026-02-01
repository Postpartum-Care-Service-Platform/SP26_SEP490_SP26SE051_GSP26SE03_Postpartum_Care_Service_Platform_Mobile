import 'dart:io';
import '../../domain/entities/feedback_entity.dart';
import '../../domain/entities/feedback_type_entity.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../datasources/feedback_remote_datasource.dart';
import '../models/create_feedback_request_model.dart';

/// Feedback Repository Implementation
class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;

  FeedbackRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<FeedbackTypeEntity>> getFeedbackTypes() async {
    final models = await remoteDataSource.getFeedbackTypes();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<FeedbackEntity>> getMyFeedbacks() async {
    final models = await remoteDataSource.getMyFeedbacks();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<FeedbackEntity> createFeedback({
    required int feedbackTypeId,
    required String title,
    required String content,
    required int rating,
    required List<String> imagePaths,
  }) async {
    final request = CreateFeedbackRequestModel(
      feedbackTypeId: feedbackTypeId,
      title: title,
      content: content,
      rating: rating,
      images: imagePaths.map((path) => File(path)).toList(),
    );

    final model = await remoteDataSource.createFeedback(request);
    return model.toEntity();
  }
}
