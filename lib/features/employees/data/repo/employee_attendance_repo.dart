import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/employee_attendance_model.dart';

class EmployeeAttendanceRepository {
  Future<EmployeeAttendanceResponse> getEmployeeAttendance(int employeeId, {int page = 1, int limit = 10}) async {
    final String url = ApiConstants.EmployeeAttendance.replaceFirst("{id}", employeeId.toString());
    final Response response = await ApiConfig.dio.get(
      url,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data == null || response.data['error'] == true) {
      throw Exception(response.data?['message'] ?? "Failed to load attendance");
    }

    return EmployeeAttendanceResponse.fromJson(response.data);
  }
}
