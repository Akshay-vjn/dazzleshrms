
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
      totalItems: data['totalItems'],
      totalPages: data['totalPages'],
      currentPage: data['currentPage'],
      records: List<PendingLeaveItem>.from(
        (data['data'] as List).map(
              (e) => PendingLeaveItem.fromJson(e),
        ),
      ),
    );
  }
}

class PendingLeaveItem {
  final int logId;
  final int employeeId;
  final String date;
  final String requestedType;
  final String daysTaken;
  final String source;

  PendingLeaveItem({
    required this.logId,
    required this.employeeId,
    required this.date,
    required this.requestedType,
    required this.daysTaken,
    required this.source,
  });

  factory PendingLeaveItem.fromJson(Map<String, dynamic> json) {
    return PendingLeaveItem(
      logId: json['logId'],
      employeeId: json['employeeId'],
      date: json['date'],
      requestedType: json['requestedType'],
      daysTaken: json['daysTaken'],
      source: json['source'],
    );
  }
}
