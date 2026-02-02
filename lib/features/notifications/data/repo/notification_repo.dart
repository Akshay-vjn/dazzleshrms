import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio = ApiConfig.dio;

  Future<NotificationData> fetchAllNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.notifications,
        queryParameters: {
          "page": page,
          "limit": limit,
        },
      );

      return NotificationResponse.fromJson(response.data).data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw 'Service is temporarily unavailable (502). Please try again later.';
      }
      if (e.response?.statusCode == 500) {
        throw 'Internal Server Error. Please try again later.';
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to fetch notifications';
      throw (message);
    }
  }
}
