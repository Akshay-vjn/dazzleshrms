import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/upcoming_leave_model.dart';

/// ================= REPOSITORY PROVIDER =================
final upcomingLeaveRepositoryProvider =
Provider<UpcomingLeaveRepository>((ref) {
  return UpcomingLeaveRepository();
});

/// ================= REPOSITORY =================
class UpcomingLeaveRepository {
  final Dio _dio = ApiConfig.dio;

  Future<UpcomingLeaveResponse> fetchUpcomingLeaves({
    required int page,
    required int limit,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.upcomingLeaves,
        queryParameters: {
          "page": page,
          "limit": limit,
        },
        cancelToken: cancelToken,
      );

      return UpcomingLeaveResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Failed to fetch upcoming leaves';
      throw Exception(message);
    }
  }
}
