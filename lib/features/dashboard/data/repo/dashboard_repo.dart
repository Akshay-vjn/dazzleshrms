import 'package:dazzleshrms/core/api_config/api_config.dart';
import 'package:dazzleshrms/core/api_constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../models/dashboard_response.dart';

class DashboardRepository {
  final Dio _dio = ApiConfig.dio;

  Future<DashboardModel> fetchDashboard() async {
    try {
      final response = await _dio.get(ApiConstants.dashboard);
      return DashboardModel.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Failed to fetch dashboard';
      throw Exception(message);
    }
  }
}


