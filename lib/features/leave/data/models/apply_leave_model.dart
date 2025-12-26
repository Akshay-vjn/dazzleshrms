class ApplyLeaveResponse {
  final int status;
  final bool error;
  final String message;
  final AppliedLeave data;

  ApplyLeaveResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory ApplyLeaveResponse.fromJson(Map<String, dynamic> json) {
    return ApplyLeaveResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      data: AppliedLeave.fromJson(json['data']),
    );
  }
}

class AppliedLeave {
  final int leaveRoasterId;
  final int employeeId;
  final int storeId;
  final int leaveTypeId;
  final String fromDate;
  final String toDate;
  final String note;
  final String status;
  final String? approvedBy;
  final String? rejectReason;
  final String createdAt;

  AppliedLeave({
    required this.leaveRoasterId,
    required this.employeeId,
    required this.storeId,
    required this.leaveTypeId,
    required this.fromDate,
    required this.toDate,
    required this.note,
    required this.status,
    this.approvedBy,
    this.rejectReason,
    required this.createdAt,
  });

  factory AppliedLeave.fromJson(Map<String, dynamic> json) {
    return AppliedLeave(
      leaveRoasterId: json['leaveRoasterId'],
      employeeId: json['employeeId'],
      storeId: json['storeId'],
      leaveTypeId: json['leaveTypeId'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      note: json['note'],
      status: json['status'],
      approvedBy: json['approvedBy'],
      rejectReason: json['rejectReason'],
      createdAt: json['created_at'],
    );
  }
}
