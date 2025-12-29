class AppliedLeaveItem {
  final int leaveRoasterId;
  final int employeeId;
  final String employeeName;
  final String fromDate;
  final String toDate;
  final String leaveType;
  final String status;
  final DateTime appliedAt;

  AppliedLeaveItem({
    required this.leaveRoasterId,
    required this.employeeId,
    required this.employeeName,
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    required this.status,
    required this.appliedAt,
  });

  factory AppliedLeaveItem.fromJson(Map<String, dynamic> json) {
    return AppliedLeaveItem(
      leaveRoasterId: json['leaveRoasterId'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      leaveType: json['leaveType'],
      status: json['status'],
      appliedAt: DateTime.parse(json['appliedAt']),
    );
  }
}

class AppliedLeaveData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<AppliedLeaveItem> records;

  AppliedLeaveData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory AppliedLeaveData.fromJson(Map<String, dynamic> json) {
    return AppliedLeaveData(
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      records: (json['data'] as List)
          .map((e) => AppliedLeaveItem.fromJson(e))
          .toList(),
    );
  }
}
class LeaveActionResponse {
  final bool success;
  final String message;
  final String newStatus;

  LeaveActionResponse({
    required this.success,
    required this.message,
    required this.newStatus,
  });

  factory LeaveActionResponse.fromJson(Map<String, dynamic> json) {
    return LeaveActionResponse(
      success: json['success'],
      message: json['message'],
      newStatus: json['newStatus'],
    );
  }
}
