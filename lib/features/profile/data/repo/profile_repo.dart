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
      final message =
          e.response?.data?['message'] ?? 'Failed to fetch profile';
      throw (message);
    }
  }
}


