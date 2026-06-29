import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/break_history_response.dart';

class BreakHistoryRepo {
  final Dio _dio = ApiConfig.dio;

  Future<BreakHistoryResponse> getBreakHistory({required String date}) async {
    try {
      final response = await _dio.get(
        ApiConstants.breakHistory,
        queryParameters: {'date': date},
      );
      return BreakHistoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      developer.log(
        'Failed to get Break history: ${e.message}',
        name: 'BreakHistoryRepository',
        error: e,
      );
      throw _handleError(e);
    } catch (e) {
      developer.log(
        'Unexpected error getting Break history: ${e.toString()}',
        name: 'BreakHistoryRepository',
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
