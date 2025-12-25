import 'package:dio/dio.dart';

import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/attendance_model.dart';


class AttendanceRepository {
  final Dio _dio = ApiConfig.dio;

  Future<AttendanceApiResponse> fetchAttendance({
    required int page,
    required int limit,
  }) async {
    final response = await _dio.get(
      ApiConstants.attendance,
      queryParameters: {
        "page": page,
        "limit": limit,
      },
    );

    return AttendanceApiResponse.fromJson(response.data);
  }
}
