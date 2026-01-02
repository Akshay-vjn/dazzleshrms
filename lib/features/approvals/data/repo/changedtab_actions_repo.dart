import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/changedtab_actions_model.dart';

class ChangedTabRepository {

  Future<ChangedTabActionResponse> approveChange(int logId) async {
    try {
      final response = await ApiConfig.dio.post(
        '${ApiConstants.approveChangeLeave}/$logId',
      );

      return ChangedTabActionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to approve change request',
      );
    }
  }

  Future<ChangedTabActionResponse> rejectChange(int logId) async {
    try {
      final response = await ApiConfig.dio.post(
        '${ApiConstants.rejectChangeLeave}/$logId',
      );

      return ChangedTabActionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to reject change request',
      );
    }
  }
}
