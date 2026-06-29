import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../../../dashboard/data/models/attendance_qr_request.dart';
import '../../../dashboard/data/models/attendance_qr_response.dart';
import '../models/break_status_response.dart';

class BreakqrRepo {
  final Dio _dio = ApiConfig.dio;

  Future<AttendanceQrResponse> generateQr({
    required String method,
    required double lat,
    required double lng,
    required double accuracy,
  }) async {
    try {
      developer.log(
        'Generating Break QR for $method at location: ($lat, $lng)',
        name: 'BreakRepository',
      );

      final request = AttendanceQrRequest(
        method: method,
        location: LocationData(lat: lat, lng: lng, accuracy: accuracy),
      );

      final response = await _dio.get(
        ApiConstants.generateBreakQr,
        data: request.toJson(),
      );

      developer.log(
        'generateQr raw response: ${response.data}',
        name: 'BreakRepository',
      );
      developer.log('Break QR generated successfully', name: 'BreakRepository');

      return AttendanceQrResponse.fromJson(response.data);
    } on DioException catch (e) {
      developer.log(
        'Failed to generate Break QR: ${e.message}',
        name: 'BreakRepository',
        error: e,
      );
      throw _handleError(e);
    } catch (e) {
      developer.log(
        'Unexpected error generating Break QR: ${e.toString()}',
        name: 'BreakRepository',
        error: e,
      );
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<BreakStatusResponse> getBreakStatus() async {
    try {
      final response = await _dio.get(ApiConstants.breakQrStatus);
      return BreakStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      developer.log(
        'Failed to get Break QR status: ${e.message}',
        name: 'BreakRepository',
        error: e,
      );
      throw _handleError(e);
    } catch (e) {
      developer.log(
        'Unexpected error getting Break QR status: ${e.toString()}',
        name: 'BreakRepository',
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
