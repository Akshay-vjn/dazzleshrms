import 'package:dio/dio.dart';

import '../../../../core/api_constants/api_constants.dart';
import '../../../../core/storage/session_storage.dart';
import '../models/attendance_qr_model.dart';

class AttendanceQrRepo {
  AttendanceQrRepo()
    : _dio = Dio(
        BaseOptions(
          baseUrl: '${ApiConstants.mediaBaseUrl}/api/api',
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {'Content-Type': 'application/json'},
        ),
      );

  final Dio _dio;

  Future<AttendanceQrResponse> scanQr({
    String? qrData,
    String? reason,
    int? sessionPin,
  }) async {
    final token = await SessionStorage.getToken();
    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.attendanceScanQr),
        error: 'Authentication token not found',
        message: 'Authentication token not found',
        type: DioExceptionType.unknown,
      );
    }

    final payload = <String, dynamic>{};
    if (qrData != null && qrData.isNotEmpty) {
      payload['qrData'] = qrData;
    }
    if (reason != null && reason.isNotEmpty) {
      payload['reason'] = reason;
    }
    if (sessionPin != null) {
      payload['sessionPin'] = sessionPin;
    }

    final response = await _dio.post(
      ApiConstants.attendanceScanQr,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: payload,
    );

    return AttendanceQrResponse.fromJson(response.data);
  }
}
