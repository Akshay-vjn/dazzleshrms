import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/break_report_response.dart';

class BreakReportRepo {
  final Dio _dio = ApiConfig.dio;

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
        'date': date,
        if (storeId != null) 'storeId': storeId,
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
