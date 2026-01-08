class NotificationResponse {
  final int status;
  final bool error;
  final String message;
  final NotificationData data;

  NotificationResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'] ?? 0,
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: NotificationData.fromJson(json['data'] ?? {}),
    );
  }
}

class NotificationData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<NotificationItem> records;

  NotificationData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      records: (json['data'] as List?)
              ?.map((e) => NotificationItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class NotificationItem {
  final int notificationId;
  final String title;
  final String message;
  final String type;
  final int referenceId;
  final bool isRead;
  final String createdAt;

  NotificationItem({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.type,
    required this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      notificationId: json['notificationId'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      referenceId: json['referenceId'] ?? 0,
      isRead: (json['isRead'] == 1 || json['isRead'] == true),
      createdAt: json['createdAt'] ?? '',
    );
  }
}
