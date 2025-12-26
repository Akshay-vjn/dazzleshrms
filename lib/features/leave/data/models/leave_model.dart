
class LeaveModel {
  final LeaveData data;

  LeaveModel({required this.data});

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      data: LeaveData.fromJson(json['data']),
    );
  }
}

class LeaveData {
  final LeaveSummary summary;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<LeaveItem> records;

  LeaveData({
    required this.summary,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      summary: LeaveSummary.fromJson(json['summary']),
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      records: (json['data'] as List)
          .map((e) => LeaveItem.fromJson(e))
          .toList(),
    );
  }
}

class LeaveSummary {
  final double totalLeaves;
  final double usedLeaves;
  final double availableLeaves;

  LeaveSummary({
    required this.totalLeaves,
    required this.usedLeaves,
    required this.availableLeaves,
  });

  factory LeaveSummary.fromJson(Map<String, dynamic> json) {
    return LeaveSummary(
      totalLeaves: (json['totalLeaves'] as num).toDouble(),
      usedLeaves: (json['usedLeaves'] as num).toDouble(),
      availableLeaves: (json['availableLeaves'] as num).toDouble(),
    );
  }
}

class LeaveItem {
  final int leaveRoasterId;
  final String fromDate;
  final String toDate;
  final String leaveType;
  final String status;
  final String? approvedBy;
  final String? rejectedBy;

  LeaveItem({
    required this.leaveRoasterId,
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    required this.status,
    this.approvedBy,
    this.rejectedBy,
  });

  factory LeaveItem.fromJson(Map<String, dynamic> json) {
    return LeaveItem(
      leaveRoasterId: json['leaveRoasterId'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      leaveType: json['leaveType'],
      status: json['status'],
      approvedBy: json['approvedBy'],
      rejectedBy: json['rejectedBy'],
    );
  }
}
