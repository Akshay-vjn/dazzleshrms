class PendingLeaveResponse {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<PendingLeaveItem> records;

  PendingLeaveResponse({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory PendingLeaveResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return PendingLeaveResponse(
      totalItems: data['totalItems'] ?? 0,
      totalPages: data['totalPages'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      records: (data['data'] as List? ?? [])
          .map((e) => PendingLeaveItem.fromJson(e))
          .toList(),
    );
  }
}

class PendingLeaveItem {
  final int logId;
  final int employeeId;
  final String employeeName;
  final String storeName;
  final String date;
  final String changesFrom;
  final String changesTo;
  final String daysTaken;
  final String source;

  PendingLeaveItem({
    required this.logId,
    required this.employeeId,
    required this.employeeName,
    required this.storeName,
    required this.date,
    required this.changesFrom,
    required this.changesTo,
    required this.daysTaken,
    required this.source,
  });

  factory PendingLeaveItem.fromJson(Map<String, dynamic> json) {
    return PendingLeaveItem(
      logId: json['logId'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'] ?? '',
      storeName: json['storeName'] ?? '',
      date: json['date'],
      changesFrom: json['changesFrom'] ?? '',
      changesTo: json['changesTo'] ?? '',
      daysTaken: json['daysTaken'] ?? '0.00',
      source: json['source'] ?? '',
    );
  }
}
