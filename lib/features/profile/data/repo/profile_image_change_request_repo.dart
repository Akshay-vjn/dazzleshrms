import 'package:dio/dio.dart';

import 'package:dazzleshrms/core/api_config/api_config.dart';
import 'package:dazzleshrms/core/api_constants/api_constants.dart';
import '../models/profile_image_change_request.dart';

class ProfileImageChangeRequestRepository {
  final Dio _dio = ApiConfig.dio;

  Future<List<ProfileImageChangeRequest>> fetchPendingRequests() async {
    try {
      final response = await _dio.get(ApiConstants.profileChangeRequests);
      final body = response.data as Map<String, dynamic>;
      if (body['error'] == true) {
        throw body['message']?.toString() ?? 'Failed to load image requests';
      }
      final data = body['data'] as List<dynamic>? ?? const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(ProfileImageChangeRequest.fromJson)
          .toList();
    } on DioException catch (error) {
      throw _messageFor(error, 'Failed to load image requests');
    }
  }

  Future<String> approve(int requestId) =>
      _submit(ApiConstants.approveProfileChangeRequest(requestId));

  Future<String> reject(int requestId) =>
      _submit(ApiConstants.rejectProfileChangeRequest(requestId));

  Future<String> _submit(String endpoint) async {
    try {
      final response = await _dio.post(endpoint);
      final body = response.data as Map<String, dynamic>;
      if (body['error'] == true) {
        throw body['message']?.toString() ?? 'Unable to update image request';
      }
      return body['message']?.toString() ??
          'Image request updated successfully';
    } on DioException catch (error) {
      throw _messageFor(error, 'Unable to update image request');
    }
  }

  String _messageFor(DioException error, String fallback) =>
      error.response?.data is Map
      ? (error.response?.data['message']?.toString() ?? fallback)
      : fallback;
}
