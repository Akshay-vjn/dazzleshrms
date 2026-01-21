class CreateAnnouncementResponse {
  final int status;
  final bool error;
  final String message;
  final AnnouncementData? data;

  CreateAnnouncementResponse({
    required this.status,
    required this.error,
    required this.message,
    this.data,
  });

  factory CreateAnnouncementResponse.fromJson(Map<String, dynamic> json) {
    return CreateAnnouncementResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      data: json['data'] != null ? AnnouncementData.fromJson(json['data']) : null,
    );
  }
}

class AnnouncementData {
  final int announcementId;
  final String title;
  final String announcement;
  final int createdBy;
  final String status;
  final String modifiedAt;
  final String createdAt;
  final String? attachment;

  AnnouncementData({
    required this.announcementId,
    required this.title,
    required this.announcement,
    required this.createdBy,
    required this.status,
    required this.modifiedAt,
    required this.createdAt,
    this.attachment,
  });

  factory AnnouncementData.fromJson(Map<String, dynamic> json) {
    return AnnouncementData(
      announcementId: json['announcementId'],
      title: json['title'],
      announcement: json['anouncement'] ?? json['announcement'] ?? '',
      createdBy: json['createdBy'],
      status: json['status'],
      modifiedAt: json['modified_at'],
      createdAt: json['created_at'],
      attachment: json['attachment'],
    );
  }
}
