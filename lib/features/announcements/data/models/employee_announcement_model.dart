import '../../../../core/api_constants/api_constants.dart';

class EmployeeAnnouncementResponse {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<EmployeeAnnouncementItem> records;

  EmployeeAnnouncementResponse({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory EmployeeAnnouncementResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return EmployeeAnnouncementResponse(
      totalItems: data['totalItems'] ?? 0,
      totalPages: data['totalPages'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      records: (data['data'] as List)
          .map((e) => EmployeeAnnouncementItem.fromJson(e))
          .toList(),
    );
  }
}

class EmployeeAnnouncementItem {
  final int announcementId;
  final String title;
  final String announcement;
  final String createdBy;
  final String createdAt;
  final String? attachment;

  EmployeeAnnouncementItem({
    required this.announcementId,
    required this.title,
    required this.announcement,
    required this.createdBy,
    required this.createdAt,
    this.attachment,
  });

  factory EmployeeAnnouncementItem.fromJson(Map<String, dynamic> json) {
    String? attachmentPath = json['attachmentUrl'] ?? json['attachment'];
    if (attachmentPath != null && attachmentPath.isNotEmpty && !attachmentPath.startsWith('http')) {
      attachmentPath = '${ApiConstants.mediaBaseUrl}$attachmentPath';
    }

    return EmployeeAnnouncementItem(
      announcementId: json['announcementId'],
      title: json['title'] ?? '',
      announcement: json['announcement'] ?? json['anouncement'] ?? '',
      createdBy: json['createdByName'] ?? json['createdBy'] ?? '',
      createdAt: json['createdAt'] ?? '',
      attachment: attachmentPath,
    );
  }
}
