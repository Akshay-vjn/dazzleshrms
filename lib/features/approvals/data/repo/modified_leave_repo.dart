
import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/modified_leaves_model.dart';

class PendingLeaveRepository {
  final Dio _dio = ApiConfig.dio;

  Future<PendingLeaveResponse> fetchPendingLeaves({
    required int page,
    required int limit,
    int? designationId,
    int? storeId,
  }) async {
    final response = await _dio.get(
      ApiConstants.getPendingLeaves,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (designationId != null) 'designation': designationId,
        if (storeId != null) 'store': storeId,
      },
    );

    return PendingLeaveResponse.fromJson(response.data);
  }
}
