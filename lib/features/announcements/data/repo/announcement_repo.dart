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

      // Send IDs as arrays (not comma-separated strings)
      if (storeIds != null && storeIds.isNotEmpty) {
        data["storeIds"] = storeIds;
      }
      if (employeeIds != null && employeeIds.isNotEmpty) {
        data["employeeIds"] = employeeIds;
      }
      if (designationIds != null && designationIds.isNotEmpty) {
        data["designationIds"] = designationIds;
      }

      FormData formData;
      
      if (attachmentPath != null) {
        // When there's an attachment, we need to send as FormData
        // For FormData, we need to send array values differently
        final Map<String, dynamic> formDataMap = {
          "title": title,
          "announcement": announcement,
        };
        
        if (storeIds != null && storeIds.isNotEmpty) {
          for (int i = 0; i < storeIds.length; i++) {
            formDataMap["storeIds[$i]"] = storeIds[i];
          }
        }
        if (employeeIds != null && employeeIds.isNotEmpty) {
          for (int i = 0; i < employeeIds.length; i++) {
            formDataMap["employeeIds[$i]"] = employeeIds[i];
          }
        }
        if (designationIds != null && designationIds.isNotEmpty) {
          for (int i = 0; i < designationIds.length; i++) {
            formDataMap["designationIds[$i]"] = designationIds[i];
          }
        }
        
        formDataMap["attachment"] = await MultipartFile.fromFile(
          attachmentPath,
          filename: attachmentPath.split('/').last,
        );
        
        formData = FormData.fromMap(formDataMap);
      } else {
        // Without attachment, send as regular JSON
        final response = await _dio.post(
          ApiConstants.announcement,
          data: data,
        );
        return CreateAnnouncementResponse.fromJson(response.data);
      }

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

  /// Fetch employees filtered by storeId and/or designationId
  Future<List<Employee>> fetchEmployeesByStoreAndDesignation({
    int? storeId,
    int? designationId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (storeId != null) queryParams['storeId'] = storeId;
      if (designationId != null) queryParams['designationId'] = designationId;

      final response = await _dio.get(
        ApiConstants.storeEmployees,
        queryParameters: queryParams,
      );
      
      if (response.data == null || response.data['error'] == true) {
        throw Exception(response.data?['message'] ?? "Failed to fetch employees");
      }
      return EmployeeResponse.fromJson(response.data).data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? "Failed to fetch employees";
      throw (message);
    }
  }

  /// Fetch all employees without store filter (for "All Stores" selection)
  Future<List<Employee>> fetchAllEmployees() async {
    try {
      final response = await _dio.get(ApiConstants.myEmployees);
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
      if (e.response?.statusCode == 502) {
        throw 'Service is temporarily unavailable (502). Please try again later.';
      }
      if (e.response?.statusCode == 500) {
        throw 'Internal Server Error. Please try again later.';
      }
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
