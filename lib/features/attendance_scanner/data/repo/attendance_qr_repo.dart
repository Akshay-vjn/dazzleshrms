import 'package:dio/dio.dart';

import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/attendance_qr_model.dart';

class StoreQrRepository {
  final Dio _dio = ApiConfig.dio;

  /// Unified scan endpoint that handles CHECKIN, CHECKOUT,
  /// PERMISSION_IN, PERMISSION_OUT based on `method` in qrData.
  Future<StoreQrCheckinResponse> scanQr({
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

    return StoreQrCheckinResponse.fromJson(response.data);
  }
}

