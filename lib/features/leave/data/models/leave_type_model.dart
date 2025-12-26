class LeaveTypeResponse {
  final int status;
  final bool error;
  final String message;
  final List<LeaveType> data;

  LeaveTypeResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory LeaveTypeResponse.fromJson(Map<String, dynamic> json) {
    return LeaveTypeResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => LeaveType.fromJson(e))
          .toList(),
    );
  }
}

class LeaveType {
  final int leaveId;
  final String leaveType;

  LeaveType({
    required this.leaveId,
    required this.leaveType,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      leaveId: json['leaveId'],
      leaveType: json['leaveType'],
    );
  }
}
