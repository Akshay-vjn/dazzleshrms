import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../../../announcements/data/models/store_model.dart';
import '../models/applied_leave_model.dart';
import '../models/designation_model.dart';
import '../models/leave_approval_clash_model.dart';

class LeaveApprovalRepository {
  final Dio _dio = ApiConfig.dio;

  Future<AppliedLeaveData> fetchAppliedLeaves({
    required int page,
    required int limit,
    int? designationId,
    int? storeId,
  }) async {
    final response = await _dio.get(
      ApiConstants.appliedLeaves,
      queryParameters: {
        "page": page,
        "limit": limit,
        if (designationId != null) "designation": designationId,
        if (storeId != null) "store": storeId,
      },
    );

    return AppliedLeaveData.fromJson(response.data['data']);
  }

  Future<LeaveActionResponse> approveLeave({
    required int leaveRoasterId,
    required List<Map<String, String>> decisions,
    String? reason,
  }) async {
    final response = await _dio.post(
      ApiConstants.approveLeave,
      data: {
        "leaveRoasterId": leaveRoasterId,
        "decisions": decisions,
        if (reason != null) "rejectReason": reason,
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

  Future<List<Designation>> fetchDesignations() async {
    try {
      final response = await _dio.get(ApiConstants.designations);
      return DesignationResponse.fromJson(response.data).data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to fetch designations';
      throw (message);
    }
  }

  Future<List<Store>> fetchStores() async {
    try {
      final response = await _dio.get(ApiConstants.stores);
      return StoreResponse.fromJson(response.data).data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to fetch stores';
      throw (message);
    }
  }

  Future<LeaveApprovalClashResponse> fetchLeaveApprovalClash({
    required int leaveRoasterId,
  }) async {
    final response = await _dio.get(
      ApiConstants.leaveApprovalClash,
      data: {"leaveRoasterId": leaveRoasterId},
    );

    return LeaveApprovalClashResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
