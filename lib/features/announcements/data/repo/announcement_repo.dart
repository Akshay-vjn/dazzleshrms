import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/create_announcement_model.dart';

class AnnouncementRepository {
  final Dio _dio = ApiConfig.dio;

  Future<CreateAnnouncementResponse> createAnnouncement({
    required String title,
    required String announcement,
    int? storeId,
    int? employeeId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "title": title,
        "announcement": announcement,
      };

      if (storeId != null) {
        data["storeId"] = storeId;
      }
      if (employeeId != null) {
        data["employeeId"] = employeeId;
      }

      final response = await _dio.post(
        ApiConstants.announcement,
        data: data,
      );

      return CreateAnnouncementResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? "Failed to create announcement";
      throw (message);
    }
  }
}
