
import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/changed_leaves_model.dart';

class PendingLeaveRepository {
  final Dio _dio = ApiConfig.dio;

  Future<PendingLeaveResponse> fetchPendingLeaves({
    required int page,
    required int limit,
  }) async {
    final response = await _dio.get(
      ApiConstants.getPendingLeaves,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return PendingLeaveResponse.fromJson(response.data);
  }
}
