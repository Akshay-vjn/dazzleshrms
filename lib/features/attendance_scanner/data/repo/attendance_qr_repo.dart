import 'package:dio/dio.dart';

import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/attendance_qr_model.dart';

class StoreQrRepository {
  final Dio _dio = ApiConfig.dio;

  Future<StoreQrCheckinResponse> checkIn({
    required String qrData,
  }) async {
    final response = await _dio.post(
      ApiConstants.attendanceCheckin,
      data: {
        'qrData': qrData,
      },
    );

    return StoreQrCheckinResponse.fromJson(response.data);
  }

  Future<StoreQrCheckinResponse> checkOut({
    required String qrData,
  }) async {
    final response = await _dio.post(
      ApiConstants.attendanceCheckout,
      data: {
        'qrData': qrData,
      },
    );

    return StoreQrCheckinResponse.fromJson(response.data);
  }
}

