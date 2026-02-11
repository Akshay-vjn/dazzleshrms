import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/attendance_qr_request.dart';
import '../models/attendance_qr_response.dart';
import '../models/attendance_qr_status_response.dart';

class AttendanceqrRepo {
  final Dio _dio = ApiConfig.dio;

  Future<AttendanceQrResponse> generateQr({
    required String method,
    required double lat,
    required double lng,
    required double accuracy,
  }) async {
    try {
      developer.log(
        'Generating QR for $method at location: ($lat, $lng)',
        name: 'AttendanceRepository',
      );

      final request = AttendanceQrRequest(
        method: method,
        location: LocationData(
          lat: lat,
          lng: lng,
          accuracy: accuracy,
        ),
      );

      final response = await _dio.get(
        ApiConstants.generateQr,
        data: request.toJson(),
      );

      developer.log('generateQr raw response: ${response.data}',
          name: 'AttendanceRepository');
      developer.log('QR generated successfully', name: 'AttendanceRepository');

      return AttendanceQrResponse.fromJson(response.data);
    } on DioException catch (e) {
      developer.log(
        'Failed to generate QR: ${e.message}',
        name: 'AttendanceRepository',
        error: e,
      );
      throw _handleError(e);
    } catch (e) {
      developer.log(
        'Unexpected error generating QR: ${e.toString()}',
        name: 'AttendanceRepository',
        error: e,
      );
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<AttendanceQrStatusResponse> getQrStatus({
    required int qrId,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.qrStatus}/$qrId',
      );

      return AttendanceQrStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      developer.log(
        'Failed to get QR status: ${e.message}',
        name: 'AttendanceRepository',
        error: e,
      );
      throw _handleError(e);
    } catch (e) {
      developer.log(
        'Unexpected error getting QR status: ${e.toString()}',
        name: 'AttendanceRepository',
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