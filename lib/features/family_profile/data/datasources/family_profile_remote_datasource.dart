import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/family_profile_model.dart';
import '../models/member_type_model.dart';
import '../models/create_family_profile_request_model.dart';
import '../models/update_family_profile_request_model.dart';

/// Remote data source for family profile
abstract class FamilyProfileRemoteDataSource {
  Future<List<FamilyProfileModel>> getMyFamilyProfiles();
  Future<List<MemberTypeModel>> getMemberTypes();
  Future<FamilyProfileModel> createFamilyProfile(
    CreateFamilyProfileRequestModel request,
  );
  Future<FamilyProfileModel> updateFamilyProfile(
    int id,
    UpdateFamilyProfileRequestModel request,
  );
}

class FamilyProfileRemoteDataSourceImpl
    implements FamilyProfileRemoteDataSource {
  final Dio dio;

  FamilyProfileRemoteDataSourceImpl({Dio? dio})
      : dio = dio ?? ApiClient.dio;

  @override
  Future<List<FamilyProfileModel>> getMyFamilyProfiles() async {
    try {
      final response = await dio.get(
        ApiEndpoints.getMyFamilyProfiles,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => FamilyProfileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load family profiles: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<MemberTypeModel>> getMemberTypes() async {
    try {
      final response = await dio.get(
        ApiEndpoints.getMemberTypes,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => MemberTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load member types: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<FamilyProfileModel> createFamilyProfile(
    CreateFamilyProfileRequestModel request,
  ) async {
    try {
      final formData = request.toFormData();
      final formDataMap = <String, dynamic>{};

      // Convert to FormData for multipart/form-data
      for (final entry in formData.entries) {
        if (entry.value is File) {
          formDataMap[entry.key] = await MultipartFile.fromFile(
            (entry.value as File).path,
            filename: (entry.value as File).path.split('/').last,
          );
        } else {
          formDataMap[entry.key] = entry.value;
        }
      }

      final response = await dio.post(
        ApiEndpoints.createFamilyProfile,
        data: FormData.fromMap(formDataMap),
      );

      return FamilyProfileModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to create family profile: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<FamilyProfileModel> updateFamilyProfile(
    int id,
    UpdateFamilyProfileRequestModel request,
  ) async {
    try {
      final formData = request.toFormData();
      final formDataMap = <String, dynamic>{};

      // Convert to FormData for multipart/form-data
      for (final entry in formData.entries) {
        if (entry.value is File) {
          formDataMap[entry.key] = await MultipartFile.fromFile(
            (entry.value as File).path,
            filename: (entry.value as File).path.split('/').last,
          );
        } else {
          formDataMap[entry.key] = entry.value;
        }
      }

      final response = await dio.put(
        ApiEndpoints.updateFamilyProfile(id),
        data: FormData.fromMap(formDataMap),
      );

      return FamilyProfileModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to update family profile: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
