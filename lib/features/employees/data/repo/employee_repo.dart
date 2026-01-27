import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/employee_model.dart';

class EmployeeRepository {
  Future<EmployeeListResponse> getTeamEmployees({int page = 1, int limit = 10}) async {
    final Response response = await ApiConfig.dio.get(
      ApiConstants.myEmployees,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data == null || response.data['error'] == true) {
      throw Exception(response.data?['message'] ?? "Failed to load team members");
    }

    return EmployeeListResponse.fromJson(response.data);
  }
}
