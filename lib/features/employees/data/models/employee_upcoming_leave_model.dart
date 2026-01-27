class EmployeeUpcomingLeaveResponse {
  final int status;
  final bool error;
  final String message;
  final EmployeeUpcomingLeaveData data;

  EmployeeUpcomingLeaveResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EmployeeUpcomingLeaveResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeUpcomingLeaveResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      data: EmployeeUpcomingLeaveData.fromJson(json['data']),
    );
  }
}

class EmployeeUpcomingLeaveData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<EmployeeUpcomingLeaveItem> records;

  EmployeeUpcomingLeaveData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory EmployeeUpcomingLeaveData.fromJson(Map<String, dynamic> json) {
    return EmployeeUpcomingLeaveData(
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      records: (json['data'] as List?)
              ?.map((e) => EmployeeUpcomingLeaveItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EmployeeUpcomingLeaveItem {
  final int leaveLogId;
  final String date;
  final String type;
  final int leaveTypeId;
  final String source;
  final String status;

  EmployeeUpcomingLeaveItem({
    required this.leaveLogId,
    required this.date,
    required this.type,
    required this.leaveTypeId,
    required this.source,
    required this.status,
  });

  factory EmployeeUpcomingLeaveItem.fromJson(Map<String, dynamic> json) {
    return EmployeeUpcomingLeaveItem(
      leaveLogId: json['leaveLogId'] ?? 0,
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      leaveTypeId: json['leaveTypeId'] ?? 0,
      source: json['source'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
