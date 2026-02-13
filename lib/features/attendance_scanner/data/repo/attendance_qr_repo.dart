import 'package:dio/dio.dart';

import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/attendance_qr_model.dart';

class AttendanceQrRepo {
  final Dio _dio = ApiConfig.dio;

  Future<AttendanceQrResponse> scanQr({
    required String qrData,
    String? reason,
  }) async {
    final response = await _dio.post(
      ApiConstants.attendanceScanQr,
      data: {
        'qrData': qrData,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );

    return AttendanceQrResponse.fromJson(response.data);
  }
}

