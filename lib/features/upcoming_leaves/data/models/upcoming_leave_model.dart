class UpcomingLeaveResponse {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<UpcomingLeaveItem> records;

  UpcomingLeaveResponse({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory UpcomingLeaveResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return UpcomingLeaveResponse(
      totalItems: data['totalItems'] ?? 0,
      totalPages: data['totalPages'] ?? 1,
      currentPage: data['currentPage'] ?? 1,
      records: List<UpcomingLeaveItem>.from(
        (data['data'] as List).map(
              (e) => UpcomingLeaveItem.fromJson(e),
        ),
      ),
    );
  }
}

class UpcomingLeaveItem {
  final int leaveId;
  final String date;
  final String type;
  final int? leaveTypeId;
  final String source;
  final String status;

  UpcomingLeaveItem({
    required this.leaveId,
    required this.date,
    required this.type,
    required this.leaveTypeId,
    required this.source,
    required this.status,
  });

  factory UpcomingLeaveItem.fromJson(Map<String, dynamic> json) {
    return UpcomingLeaveItem(
      leaveId: json['leaveLogId'] ?? 0,
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      leaveTypeId: json['leaveTypeId'],
      source: json['source'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
