import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/change_leaverequest_model.dart';

final changeLeaveRepositoryProvider =
Provider<ChangeLeaveRepository>((ref) {
  return ChangeLeaveRepository();
});

class ChangeLeaveRepository {
  final Dio _dio = ApiConfig.dio;

  Future<ChangeLeaveResponse> sendChangeRequest({
    required int logId,
    String? newType,
    int? newTypeId,
  }) async {
    final body = {
      "logId": logId,
      if (newType != null) "newType": newType,
      if (newTypeId != null) "newTypeId": newTypeId,
    };

    final response = await _dio.post(
      ApiConstants.changeLeaveRequest,
      data: body,
    );

    return ChangeLeaveResponse.fromJson(response.data);
  }
}
