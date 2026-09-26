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
      throw _handleError(e, fallback: 'Failed to fetch profile');
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
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data['error'] == false) {
        return data['data']['profileImage'] as String? ?? '';
      } else {
        throw data['message'] ?? 'Failed to update profile image';
      }
    } on DioException catch (e) {
      throw _handleError(e, fallback: 'Failed to update profile image');
    }
  }

  Future<String> requestProfileImageChange() async {
    try {
      final response = await _dio.post(ApiConstants.profileChangeRequest);

      final data = response.data;
      if (data is Map && data['error'] == false) {
        return data['message']?.toString() ??
            'Profile image change request submitted successfully';
      }
      throw (data is Map
          ? (data['message'] ?? 'Failed to submit change request')
          : 'Failed to submit change request');
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback: 'Failed to submit profile image change request',
      );
    }
  }

  String _handleError(DioException e, {required String fallback}) {
    if (e.response?.statusCode == 502) {
      return 'Service is temporarily unavailable (502). Please try again later.';
    }
    if (e.response?.statusCode == 500) {
      return 'Internal Server Error. Please try again later.';
    }
    return e.response?.data?['message']?.toString() ?? fallback;
  }
}
