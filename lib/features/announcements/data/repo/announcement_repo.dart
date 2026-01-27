import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../../../approvals/data/models/designation_model.dart';
import '../models/create_announcement_model.dart';
import '../models/store_model.dart';
import '../models/employee_model.dart';
import '../models/employee_announcement_model.dart';

class AnnouncementRepository {
  final Dio _dio = ApiConfig.dio;

  Future<CreateAnnouncementResponse> createAnnouncement({
    required String title,
    required String announcement,
    List<int>? storeIds,
    List<int>? employeeIds,
    List<int>? designationIds,
    String? attachmentPath,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "title": title,
        "announcement": announcement,
      };

      if (storeIds != null && storeIds.isNotEmpty) {
        data["storeId"] = storeIds.join(',');
      }
      if (employeeIds != null && employeeIds.isNotEmpty) {
        data["employeeId"] = employeeIds.join(',');
      }
      if (designationIds != null && designationIds.isNotEmpty) {
        data["designationId"] = designationIds.join(',');
      }

      if (attachmentPath != null) {
        data["attachment"] = await MultipartFile.fromFile(
          attachmentPath,
          filename: attachmentPath.split('/').last,
        );
      }

      final formData = FormData.fromMap(data);

      final response = await _dio.post(
        ApiConstants.announcement,
        data: formData,
      );

      return CreateAnnouncementResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? "Failed to create announcement";
      throw (message);
    }
  }
  Future<bool> approveAnnouncement(int id) async {
    try {
      final response = await _dio.post('${ApiConstants.approveAnnouncement}/$id');
      return response.data['error'] == false;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? "Failed to approve announcement";
      throw (message);
    }
  }

  Future<bool> rejectAnnouncement(int id) async {
    try {
      final response = await _dio.post('${ApiConstants.rejectAnnouncement}/$id');
      return response.data['error'] == false;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? "Failed to reject announcement";
      throw (message);
    }
  }

  Future<List<Store>> fetchStores() async {
    try {
      final response = await _dio.get(ApiConstants.stores);
      if (response.data == null || response.data['error'] == true) {
         throw Exception(response.data?['message'] ?? "Failed to fetch stores");
      }
      return StoreResponse.fromJson(response.data).data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? "Failed to fetch stores";
      throw (message);
    }
  }

  Future<List<Employee>> fetchEmployees(int storeId) async {
    try {
      final response = await _dio.get('${ApiConstants.stores}/$storeId/employees');
      if (response.data == null || response.data['error'] == true) {
         throw Exception(response.data?['message'] ?? "Failed to fetch employees");
      }
      return EmployeeResponse.fromJson(response.data).data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? "Failed to fetch employees";
      throw (message);
    }
  }
  
  Future<EmployeeAnnouncementResponse> fetchEmployeeAnnouncements() async {
    try {
      final response = await _dio.get(ApiConstants.getEmployeeAnnouncements);
      if (response.data == null || response.data['error'] == true) {
         throw Exception(response.data?['message'] ?? "Failed to fetch announcements");
      }
      return EmployeeAnnouncementResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? "Failed to fetch announcements";
      throw (message);
    }
  }

  Future<List<Designation>> fetchDesignations() async {
    try {
      final response = await _dio.get(ApiConstants.designations);
      if (response.data == null || response.data['error'] == true) {
        throw Exception(response.data?['message'] ?? "Failed to fetch designations");
      }
      return DesignationResponse.fromJson(response.data).data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? "Failed to fetch designations";
      throw (message);
    }
  }
}
