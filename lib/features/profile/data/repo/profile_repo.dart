import 'dart:io';
import 'package:dio/dio.dart';

import 'package:dazzleshrms/core/api_config/api_config.dart';
import 'package:dazzleshrms/core/api_constants/api_constants.dart';
import '../models/profile_response.dart';

class ProfileRepository {
  final Dio _dio = ApiConfig.dio;

  Future<ProfileModel> fetchProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw 'Service is temporarily unavailable (502). Please try again later.';
      }
      if (e.response?.statusCode == 500) {
        throw 'Internal Server Error. Please try again later.';
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to fetch profile';
      throw (message);
    }
  }

  Future<String> updateProfileImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.put(
        ApiConstants.profile,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data;
      if (data['error'] == false) {
        return data['data']['profileImage'] as String? ?? '';
      } else {
        throw data['message'] ?? 'Failed to update profile image';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw 'Service is temporarily unavailable (502). Please try again later.';
      }
      if (e.response?.statusCode == 500) {
        throw 'Internal Server Error. Please try again later.';
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to update profile image';
      throw (message);
    }
  }

  Future<void> removeProfileImage() async {
    try {
      final response = await _dio.delete(ApiConstants.profile);

      final data = response.data;
      if (data is Map && data['error'] == false) {
        return;
      }
      throw (data is Map
          ? (data['message'] ?? 'Failed to remove profile image')
          : 'Failed to remove profile image');
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw 'Service is temporarily unavailable (502). Please try again later.';
      }
      if (e.response?.statusCode == 500) {
        throw 'Internal Server Error. Please try again later.';
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to remove profile image';
      throw (message);
    }
  }
}
