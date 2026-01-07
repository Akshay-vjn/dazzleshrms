import 'package:dio/dio.dart';
import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/announcement_model.dart';

class GetAnnouncementRepository {
  // APPROVED
  Future<AnnouncementResponse> getApprovedAnnouncements() async {
    final Response response =
    await ApiConfig.dio.get(ApiConstants.getApprovedAnnouncements);

    if (response.data == null || response.data['error'] == true) {
      throw Exception(response.data?['message'] ?? "Failed to load approved");
    }

    return AnnouncementResponse.fromJson(response.data);
  }

  // PENDING
  Future<AnnouncementResponse> getPendingAnnouncements() async {
    final Response response =
    await ApiConfig.dio.get(ApiConstants.getPendingAnnouncements);

    if (response.data == null || response.data['error'] == true) {
      throw Exception(response.data?['message'] ?? "Failed to load pending");
    }

    return AnnouncementResponse.fromJson(response.data);
  }
}
