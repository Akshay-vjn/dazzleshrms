class UsedLeaveResponse {
  final List<UsedLeaveItem> data;
  final String message;
  final bool error;

  UsedLeaveResponse({
    required this.data,
    required this.message,
    required this.error,
  });

  factory UsedLeaveResponse.fromJson(Map<String, dynamic> json) {
    return UsedLeaveResponse(
      data: (json['data'] as List?)
              ?.map((e) => UsedLeaveItem.fromJson(e))
              .toList() ??
          [],
      message: json['message'] ?? '',
      error: json['error'] ?? false,
    );
  }
}

class UsedLeaveItem {
  final String date;
  final String leaveType;
  final double daysTaken;
  final String source;

  UsedLeaveItem({
    required this.date,
    required this.leaveType,
    required this.daysTaken,
    required this.source,
  });

  factory UsedLeaveItem.fromJson(Map<String, dynamic> json) {
    return UsedLeaveItem(
      date: json['date'] ?? '',
      leaveType: json['leaveType'] ?? '',
      daysTaken: (json['daysTaken'] as num?)?.toDouble() ?? 0.0,
      source: json['source'] ?? '',
    );
  }
}
