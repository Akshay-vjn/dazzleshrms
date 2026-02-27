import 'package:dio/dio.dart';

import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/attendance_qr_model.dart';

class AttendanceQrRepo {
  final Dio _dio = ApiConfig.dio;

  Future<AttendanceQrResponse> scanQr({
    String? qrData,
    String? reason,
    int? sessionPin,
  }) async {
    final response = await _dio.post(
      ApiConstants.attendanceScanQr,
      data: {
        if (qrData != null && qrData.isNotEmpty) 'qrData': qrData,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
        if (sessionPin != null) 'sessionPin': sessionPin,
      },
    );

    return AttendanceQrResponse.fromJson(response.data);
  }
}

