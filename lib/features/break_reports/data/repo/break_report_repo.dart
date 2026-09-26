import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/break_dashboard_employee_response.dart';
import '../models/break_report_response.dart';
import '../models/employee_dashboard_attendance_response.dart';
import '../models/employee_dashboard_breaks_response.dart';
import '../models/employee_dashboard_summary_response.dart';

class BreakReportRepo {
  final Dio _dio = ApiConfig.dio;

  Future<BreakDashboardEmployeeData> getDashboardEmployees({
    int storeId = 4,
    int designationId = 19,
    int page = 1,
    int limit = 10,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.employeeByStoreAndDesignation(
          storeId: storeId,
          designationId: designationId,
        ),
        queryParameters: {
          'page': page,
          'limit': limit,
          if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
          if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
        },
      );

      final parsed = BreakDashboardEmployeeResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return parsed.data;
    } on DioException catch (e) {
      developer.log(
        'Failed to get dashboard employees: ${e.message}',
        name: 'BreakReportRepo',
        error: e,
      );
      throw _handleError(e);
    } catch (e) {
      developer.log(
        'Unexpected error getting dashboard employees: ${e.toString()}',
        name: 'BreakReportRepo',
        error: e,
      );
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<EmployeeDashboardSummaryData> getEmployeeDashboardSummary({
    required int employeeId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
      };

      final response = await _dio.get(
        ApiConstants.employeeDashboardSummary(employeeId),
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final parsed = EmployeeDashboardSummaryResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return parsed.data;
    } on DioException catch (e) {
      developer.log(
        'Failed to get employee dashboard summary: ${e.message}',
        name: 'BreakReportRepo',
        error: e,
      );
      throw _handleError(e);
    } catch (e) {
      developer.log(
        'Unexpected error getting employee dashboard summary: ${e.toString()}',
        name: 'BreakReportRepo',
        error: e,
      );
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<EmployeeDashboardAttendancePage> getEmployeeDashboardAttendance({
    required int employeeId,
    int page = 1,
    int limit = 10,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
      };

      final response = await _dio.get(
        ApiConstants.employeeDashboardAttendance(employeeId),
        queryParameters: queryParameters,
      );

      final parsed = EmployeeDashboardAttendanceResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return parsed.data;
    } on DioException catch (e) {
      developer.log(
        'Failed to get employee dashboard attendance: ${e.message}',
        name: 'BreakReportRepo',
        error: e,
      );
      throw _handleError(e);
    } catch (e) {
      developer.log(
        'Unexpected error getting employee dashboard attendance: ${e.toString()}',
        name: 'BreakReportRepo',
        error: e,
      );
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<EmployeeDashboardBreaksPage> getEmployeeDashboardBreaks({
    required int employeeId,
    int page = 1,
    int limit = 10,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
      };

      final response = await _dio.get(
        ApiConstants.employeeDashboardBreaks(employeeId),
        queryParameters: queryParameters,
      );

      final parsed = EmployeeDashboardBreaksResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return parsed.data;
    } on DioException catch (e) {
      developer.log(
        'Failed to get employee dashboard breaks: ${e.message}',
        name: 'BreakReportRepo',
        error: e,
      );
      throw _handleError(e);
    } catch (e) {
      developer.log(
        'Unexpected error getting employee dashboard breaks: ${e.toString()}',
        name: 'BreakReportRepo',
        error: e,
      );
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<BreakReportPaginatedData> getBreakReport({
    required int page,
    required int limit,
    required String date,
    int? storeId,
    int? designationId,
    int? employeeId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (date.isNotEmpty) 'date': date,
        if (storeId != null) 'storeFilter': storeId,
        if (designationId != null) 'designationId': designationId,
        if (employeeId != null) 'employeeId': employeeId,
      };

      final response = await _dio.get(
        ApiConstants.breakReport,
        queryParameters: queryParameters,
      );

      final parsed = BreakReportResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return parsed.data;
    } on DioException catch (e) {
      developer.log(
        'Failed to get break report: ${e.message}',
        name: 'BreakReportRepo',
        error: e,
      );
      throw _handleError(e);
    } catch (e) {
      developer.log(
        'Unexpected error getting break report: ${e.toString()}',
        name: 'BreakReportRepo',
        error: e,
      );
      throw 'Something went wrong. Please try again.';
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final message = error.response?.data?['message'];
        return message ?? 'An error occurred. Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
