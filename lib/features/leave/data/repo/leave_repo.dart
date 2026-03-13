
import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/leave_model.dart';
import '../models/used_leave_model.dart';

class LeaveRepository {
  Future<LeaveModel> fetchLeaves({
    required int page,
    required int limit,
    CancelToken? cancelToken,
  }) async {
    final response = await ApiConfig.dio.get(
      ApiConstants.leave,
      queryParameters: {
        "page": page,
        "limit": limit,
      },
      cancelToken: cancelToken,
    );

    return LeaveModel.fromJson(response.data);
  }
  
  Future<List<UsedLeaveItem>> fetchUsedLeaves({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await ApiConfig.dio.get(
      ApiConstants.usedLeaves,
      queryParameters: {
        "page": page,
        "limit": limit,
      },
    );

    if (response.data == null) {
      throw Exception("Failed to fetch used leaves: No response data");
    }

    if (response.data['error'] == true) {
      throw Exception(
          response.data['message'] ?? "Failed to fetch used leaves");
    }

    try {
      return UsedLeaveResponse.fromJson(response.data).data;
    } catch (e) {
      return [];
    }
  }
}

