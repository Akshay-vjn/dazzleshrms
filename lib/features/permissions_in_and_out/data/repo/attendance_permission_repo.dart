import 'package:dazzleshrms/core/api_config/api_config.dart';
import 'package:dazzleshrms/core/api_constants/api_constants.dart';

import '../models/attendance_permission_pending_model.dart';

enum PermissionApprovalType {
  inOut,
  lateEarly,
}

class AttendancePermissionRepository {
  Future<AttendancePermissionPendingResponse> fetchPending({
    int page = 1,
    int limit = 10,
    PermissionApprovalType approvalType = PermissionApprovalType.lateEarly,
  }) async {
    final endpoint = approvalType == PermissionApprovalType.inOut
        ? ApiConstants.midPermissionPending
        : ApiConstants.attendancePermissionPending;
    final response = await ApiConfig.dio.get(
      endpoint,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data == null) {
      throw Exception('No response data');
    }

    if (response.data['error'] == true) {
      throw Exception(
        (response.data['message'] ?? 'Failed to fetch pending attendance permissions')
            .toString(),
      );
    }

    return AttendancePermissionPendingResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<String> approve({
    required int permissionId,
    PermissionApprovalType approvalType = PermissionApprovalType.lateEarly,
  }) async {
    final endpoint = approvalType == PermissionApprovalType.inOut
        ? ApiConstants.midPermissionApprove
        : ApiConstants.attendancePermissionApprove;
    final response = await ApiConfig.dio.patch(
      '$endpoint/$permissionId',
    );
    if (response.data == null) {
      throw Exception('No response data');
    }
    if (response.data['error'] == true) {
      throw Exception(
        (response.data['message'] ?? 'Failed to approve attendance adjustment')
            .toString(),
      );
    }
    return (response.data['message'] ?? 'Approved successfully').toString();
  }

  Future<String> reject({
    required int permissionId,
    PermissionApprovalType approvalType = PermissionApprovalType.lateEarly,
  }) async {
    final endpoint = approvalType == PermissionApprovalType.inOut
        ? ApiConstants.midPermissionReject
        : ApiConstants.attendancePermissionReject;
    final response = await ApiConfig.dio.patch(
      '$endpoint/$permissionId',
    );
    if (response.data == null) {
      throw Exception('No response data');
    }
    if (response.data['error'] == true) {
      throw Exception(
        (response.data['message'] ?? 'Failed to reject attendance adjustment')
            .toString(),
      );
    }
    return (response.data['message'] ?? 'Rejected successfully').toString();
  }
}
