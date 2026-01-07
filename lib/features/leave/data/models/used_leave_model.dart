class UsedLeaveResponse {
  final UsedLeaveData data;
  final String message;
  final bool error;

  UsedLeaveResponse({
    required this.data,
    required this.message,
    required this.error,
  });

  factory UsedLeaveResponse.fromJson(Map<String, dynamic> json) {
    return UsedLeaveResponse(
      data: UsedLeaveData.fromJson(json['data']),
      message: json['message'],
      error: json['error'],
    );
  }
}

class UsedLeaveData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<UsedLeaveItem> records;

  UsedLeaveData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory UsedLeaveData.fromJson(Map<String, dynamic> json) {
    return UsedLeaveData(
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      records:
          (json['data'] as List).map((e) => UsedLeaveItem.fromJson(e)).toList(),
    );
  }
}

class UsedLeaveItem {
  final String date;
  final String leaveType;
  final int daysTaken; // Using int based on JSON but double might be safer if half days are possible? JSON shows 1. Assuming int for now based on example.

  UsedLeaveItem({
    required this.date,
    required this.leaveType,
    required this.daysTaken,
  });

  factory UsedLeaveItem.fromJson(Map<String, dynamic> json) {
    return UsedLeaveItem(
      date: json['date'] ?? '',
      leaveType: json['leaveType'] ?? '',
      daysTaken: json['daysTaken'] ?? 0,
    );
  }
}
