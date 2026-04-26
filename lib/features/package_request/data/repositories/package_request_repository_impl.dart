import 'package:dio/dio.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../../domain/entities/package_request_entity.dart';
import '../../domain/repositories/package_request_repository.dart';
import '../models/create_package_request_model.dart';
import '../models/package_request_model.dart';

class PackageRequestRepositoryImpl implements PackageRequestRepository {
  final Dio dio;

  PackageRequestRepositoryImpl({required this.dio});

  Future<Map<int, String?>> _getAvatarMap() async {
    try {
      final response = await dio.get(ApiEndpoints.getMyFamilyProfiles);
      final List<dynamic> data = response.data as List<dynamic>;
      return {
        for (var p in data)
          (p['id'] as num).toInt(): p['avatarUrl'] as String?
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<List<PackageRequestEntity>> getAll() async {
    try {
      final avatarMap = await _getAvatarMap();
      final response = await dio.get(ApiEndpoints.packageRequestGetAll);
      final List<dynamic> data = response.data as List<dynamic>;
      
      return data.map((json) {
        final entity = PackageRequestModel.fromJson(json as Map<String, dynamic>).toEntity();
        // Enrich avatars
        final enrichedProfiles = entity.familyProfiles.map((p) {
          return PackageRequestFamilyProfile(
            id: p.id,
            fullName: p.fullName,
            memberType: p.memberType,
            avatarUrl: avatarMap[p.id] ?? p.avatarUrl,
          );
        }).toList();
        return entity.copyWith(familyProfiles: enrichedProfiles);
      }).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách yêu cầu: $e');
    }
  }

  @override
  Future<PackageRequestEntity> getById(int id) async {
    try {
      final avatarMap = await _getAvatarMap();
      final response = await dio.get(ApiEndpoints.packageRequestGetById(id));
      final entity = PackageRequestModel.fromJson(response.data as Map<String, dynamic>).toEntity();
      
      // Enrich avatars
      final enrichedProfiles = entity.familyProfiles.map((p) {
        return PackageRequestFamilyProfile(
          id: p.id,
          fullName: p.fullName,
          memberType: p.memberType,
          avatarUrl: avatarMap[p.id] ?? p.avatarUrl,
        );
      }).toList();
      return entity.copyWith(familyProfiles: enrichedProfiles);
    } catch (e) {
      throw Exception('Không thể tải chi tiết yêu cầu: $e');
    }
  }

  @override
  Future<PackageRequestEntity> create(
      CreatePackageRequestModel request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.packageRequestCreate,
        data: request.toJson(),
      );
      return PackageRequestModel.fromJson(
              response.data as Map<String, dynamic>)
          .toEntity();
    } catch (e) {
      throw Exception('Không thể tạo yêu cầu: $e');
    }
  }

  @override
  Future<void> approve(int id) async {
    try {
      await dio.put(ApiEndpoints.packageRequestApprove(id));
    } catch (e) {
      throw Exception('Không thể chấp nhận yêu cầu: $e');
    }
  }

  @override
  Future<void> reject(int id) async {
    try {
      await dio.put(ApiEndpoints.packageRequestReject(id));
    } catch (e) {
      throw Exception('Không thể từ chối yêu cầu: $e');
    }
  }

  @override
  Future<void> requestRevision(int id, String customerFeedback) async {
    try {
      await dio.put(
        ApiEndpoints.packageRequestRevision(id),
        data: {'customerFeedback': customerFeedback},
      );
    } catch (e) {
      throw Exception('Không thể gửi yêu cầu chỉnh sửa: $e');
    }
  }
}
