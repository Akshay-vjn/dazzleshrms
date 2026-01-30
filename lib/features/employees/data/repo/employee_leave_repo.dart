import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../../../leave/data/models/used_leave_model.dart';
import '../models/employee_leave_model.dart';
import '../models/employee_pending_leave_model.dart';
import '../models/employee_upcoming_leave_model.dart';


//employee upcomingleaves

class EmployeeLeaveRepository {
  Future<EmployeeUpcomingLeaveResponse> getEmployeeUpcomingLeaves(int employeeId, {int page = 1, int limit = 10}) async {
    final String url = ApiConstants.EmployeeUpcomingLeaves.replaceFirst("{id}", employeeId.toString());
    final Response response = await ApiConfig.dio.get(
      url,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data == null || response.data['error'] == true) {
      throw Exception(response.data?['message'] ?? "Failed to load upcoming leaves");
    }

    return EmployeeUpcomingLeaveResponse.fromJson(response.data);
  }



  //pending leaves
  Future<EmployeePendingLeaveResponse> getEmployeePendingLeaves(int employeeId, {int page = 1, int limit = 10}) async {
    final String url = ApiConstants.EmployeePendingLeaves.replaceFirst("{id}", employeeId.toString());
    final Response response = await ApiConfig.dio.get(
      url,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data == null || response.data['error'] == true) {
      throw Exception(response.data?['message'] ?? "Failed to load pending leaves");
    }

    return EmployeePendingLeaveResponse.fromJson(response.data);
  }


  //approve
  Future<void> approveEmployeeLeave({
    required int leaveRoasterId,
    required List<Map<String, dynamic>> decisions,
    String? rejectReason,
  }) async {
    final Response response = await ApiConfig.dio.post(
      ApiConstants.ApproveEmployeeLeave,
      data: {
        "leaveRoasterId": leaveRoasterId,
        "decisions": decisions,
        if (rejectReason != null) "rejectReason": rejectReason,
      },
    );

    if (response.data == null || response.data['error'] == true) {
      throw Exception(response.data?['message'] ?? "Failed to approve leave");
    }
  }


  //reject
  Future<void> rejectEmployeeLeave({
    required int leaveRoasterId,
    required String rejectReason,
  }) async {
    final Response response = await ApiConfig.dio.post(
      ApiConstants.RejectEmployeeLeave,
      data: {
        "leaveRoasterId": leaveRoasterId,
        "rejectReason": rejectReason,
      },
    );

    if (response.data == null || response.data['error'] == true) {
      throw Exception(response.data?['message'] ?? "Failed to reject leave");
    }
  }


  Future<EmployeeLeaveResponse> getEmployeeLeaves(int employeeId, {int page = 1, int limit = 10}) async {
    final String url = ApiConstants.EmployeeLeaves.replaceFirst("{id}", employeeId.toString());
    final Response response = await ApiConfig.dio.get(
      url,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data == null || response.data['error'] == true) {
      throw Exception(response.data?['message'] ?? "Failed to load leaves");
    }

    return EmployeeLeaveResponse.fromJson(response.data);
  }

  Future<UsedLeaveResponse> getEmployeeUsedLeaves(int employeeId, {int page = 1, int limit = 10}) async {
    final String url = ApiConstants.EmployeeUsedLeaves.replaceFirst("{id}", employeeId.toString());
    final Response response = await ApiConfig.dio.get(
      url,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data == null || response.data['error'] == true) {
      throw Exception(response.data?['message'] ?? "Failed to load used leaves");
    }

    return UsedLeaveResponse.fromJson(response.data);
  }

  Future<void> applyEmployeeLeave(int employeeId, {
    required int leaveTypeId,
    required String fromDate,
    required String toDate,
    required String note,
  }) async {
    final String url = ApiConstants.EmployeeApplyLeave.replaceFirst("{id}", employeeId.toString());
    final Response response = await ApiConfig.dio.post(
      url,
      data: {
        "leaveTypeId": leaveTypeId,
        "fromDate": fromDate,
        "toDate": toDate,
        "note": note,
      },
    );

    if (response.data == null || response.data['error'] == true) {
      throw Exception(response.data?['message'] ?? "Failed to apply leave");
    }
  }
}
