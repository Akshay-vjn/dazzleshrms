import '../../../../core/api_constants/api_constants.dart';

class AnnouncementResponse {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<AnnouncementItem> records;

  AnnouncementResponse({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory AnnouncementResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return AnnouncementResponse(
      totalItems: data['totalItems'] ?? 0,
      totalPages: data['totalPages'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      records: (data['data'] as List)
          .map((e) => AnnouncementItem.fromJson(e))
          .toList(),
    );
  }
}

class AnnouncementItem {
  final int announcementId;
  final String title;
  final String announcement;
  final String status;
  final String? storeName;
  final String? designationName;
  final String? employeeName;
  final String createdByName;
  final String? approvedByName;
  final String? rejectedByName;
  final String createdAt;
  final String? attachment;

  AnnouncementItem({
    required this.announcementId,
    required this.title,
    required this.announcement,
    required this.status,
    this.storeName,
    this.designationName,
    this.employeeName,
    required this.createdByName,
    this.approvedByName,
    this.rejectedByName,
    required this.createdAt,
    this.attachment,
  });

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    String? attachmentPath = json['attachmentUrl'] ?? json['attachment'];
    if (attachmentPath != null && attachmentPath.isNotEmpty && !attachmentPath.startsWith('http')) {
      attachmentPath = '${ApiConstants.mediaBaseUrl}$attachmentPath';
    }

    return AnnouncementItem(
      announcementId: json['announcementId'],
      title: json['title'] ?? '',
      announcement: json['announcement'] ?? json['anouncement'] ?? '',
      status: json['status'] ?? '',
      storeName: json['storeName'],
      designationName: json['designationName'],
      employeeName: json['employeeName'],
      createdByName: json['createdByName'] ?? '',
      approvedByName: json['approvedByName'],
      rejectedByName: json['rejectedByName'],
      createdAt: json['createdAt'] ?? '',
      attachment: attachmentPath,
    );
  }
}
