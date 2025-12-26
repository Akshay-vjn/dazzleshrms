import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/leave_type_model.dart';

class LeaveTypeRepository {
  final Dio _dio = ApiConfig.dio;

  Future<LeaveTypeResponse> fetchLeaveTypes() async {
    try {
      final response = await _dio.get(ApiConstants.leaveType);
      return LeaveTypeResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw Exception("Request cancelled");
      }
      final message =
          e.response?.data?['message'] ?? "Failed to fetch leave types";
      throw (message);
    }
  }
}
