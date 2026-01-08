import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/applied_leave_model.dart';

class LeaveApprovalRepository {
  final Dio _dio = ApiConfig.dio;

  Future<AppliedLeaveData> fetchAppliedLeaves({
    required int page,
    required int limit,
  }) async {
    final response = await _dio.get(
      ApiConstants.appliedLeaves,
      queryParameters: {
        "page": page,
        "limit": limit,
      },
    );

    return AppliedLeaveData.fromJson(response.data['data']);
  }

  Future<LeaveActionResponse> approveLeave({
    required int leaveRoasterId,
    required List<Map<String, String>> decisions,
  }) async {
    final response = await _dio.post(
      ApiConstants.approveLeave,
      data: {
        "leaveRoasterId": leaveRoasterId,
        "decisions": decisions,
      },
    );

    return LeaveActionResponse.fromJson(response.data['data']);
  }

  Future<LeaveActionResponse> rejectLeave({
    required int leaveRoasterId,
    required String reason,
  }) async {
    final response = await _dio.post(
      ApiConstants.rejectLeave,
      data: {
        "leaveRoasterId": leaveRoasterId,
        "rejectReason": reason,
      },
    );

    return LeaveActionResponse.fromJson(response.data['data']);
  }
}
