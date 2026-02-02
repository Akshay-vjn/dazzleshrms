import 'package:dazzleshrms/core/api_config/api_config.dart';
import 'package:dazzleshrms/core/api_constants/api_constants.dart';
import 'package:dazzleshrms/features/auth/data/models/send_otp_model.dart';
import 'package:dazzleshrms/features/auth/data/models/verify_otp_model.dart';
import 'package:dazzleshrms/features/auth/data/models/refresh_token_model.dart';
import 'package:dio/dio.dart';


class AuthRepository {
  final Dio _dio = ApiConfig.dio;

  //SEND OTP
  Future<SendOtpModel> sendOtp({
    required String mobileNumber,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendOtp,
        data: {
          "mobileNumber": mobileNumber,
        },
      );

      return SendOtpModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw 'Service is temporarily unavailable (502). Please try again later.';
      }
      if (e.response?.statusCode == 500) {
        throw 'Internal Server Error. Please try again later.';
      }
      final message =
          e.response?.data?['message'] ?? "Failed to send OTP";
      throw (message);
    }
  }


  // VERIFY OTP
  Future<VerifyOtpModel> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: {
          "mobileNumber": mobileNumber,
          "otp": otp,
        },
      );

      return VerifyOtpModel.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? "OTP verification failed";
      throw (message);
    }
  }


  //REFRESH TOKEN
  Future<RefreshTokenModel> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {
          "refreshToken": refreshToken,
        },
      );

      return RefreshTokenModel.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? "Token refresh failed";
      throw (message);
    }
  }
}
