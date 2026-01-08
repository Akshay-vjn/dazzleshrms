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
    final response = await _dio.get(
      ApiConstants.notifications,
      queryParameters: {
        "page": page,
        "limit": limit,
      },
    );

    return NotificationResponse.fromJson(response.data).data;
  }
}
