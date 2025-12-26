import 'package:dio/dio.dart';

import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/apply_leave_model.dart';

class ApplyLeaveRepository {
  final Dio _dio = ApiConfig.dio;

  Future<ApplyLeaveResponse> applyLeave({
    required int leaveTypeId,
    required String fromDate,
    required String toDate,
    required String note,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.leave,
        data: {
          "leaveTypeId": leaveTypeId,
          "fromDate": fromDate,
          "toDate": toDate,
          "note": note,
        },
      );

      return ApplyLeaveResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? "Failed to apply leave";
      throw (message);
    }
  }
}
