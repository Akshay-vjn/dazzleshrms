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
      totalLeaves: (json['totalLeaves'] ?? 0).toDouble(),
      usedLeaves: (json['usedLeaves'] ?? 0).toDouble(),
      availableLeaves: (json['availableLeaves'] ?? 0).toDouble(),
    );
  }
}

class EmployeeLeaveRecord {
  final int leaveRoasterId;
  final String fromDate;
  final String toDate;
  final String leaveType;
  final String status;
  final String? rejectReason;
  final List<String> rejectedDates;

  EmployeeLeaveRecord({
    required this.leaveRoasterId,
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    required this.status,
    this.rejectReason,
    required this.rejectedDates,
  });

  factory EmployeeLeaveRecord.fromJson(Map<String, dynamic> json) {
    return EmployeeLeaveRecord(
      leaveRoasterId: json['leaveRoasterId'] ?? 0,
      fromDate: json['fromDate'] ?? '',
      toDate: json['toDate'] ?? '',
      leaveType: json['leaveType'] ?? '',
      status: json['status'] ?? '',
      rejectReason: json['rejectReason'],
      rejectedDates: (json['rejectedDates'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class EmployeeLeaveData {
  final LeaveSummary summary;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<EmployeeLeaveRecord> data;

  EmployeeLeaveData({
    required this.summary,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.data,
  });

  factory EmployeeLeaveData.fromJson(Map<String, dynamic> json) {
    return EmployeeLeaveData(
      summary: LeaveSummary.fromJson(json['summary'] ?? {}),
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => EmployeeLeaveRecord.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EmployeeLeaveResponse {
  final int status;
  final bool error;
  final String message;
  final EmployeeLeaveData data;

  EmployeeLeaveResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EmployeeLeaveResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeLeaveResponse(
      status: json['status'] ?? 0,
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: EmployeeLeaveData.fromJson(json['data'] ?? {}),
    );
  }
}
