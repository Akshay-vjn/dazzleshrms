class LeaveApprovalClashResponse {
  final int employeeId;
  final String employeeName;
  final String fromDate;
  final String toDate;
  final LeaveApprovalClashCalendar calendar;

  const LeaveApprovalClashResponse({
    required this.employeeId,
    required this.employeeName,
    required this.fromDate,
    required this.toDate,
    required this.calendar,
  });

  factory LeaveApprovalClashResponse.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalClashResponse(
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      employeeName: json['employeeName'] as String? ?? '',
      fromDate: json['fromDate'] as String? ?? '',
      toDate: json['toDate'] as String? ?? '',
      calendar: LeaveApprovalClashCalendar.fromJson(
        json['calendar'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class LeaveApprovalClashCalendar {
  final int totalEmployees;
  final List<LeaveApprovalClashDay> calendar;

  const LeaveApprovalClashCalendar({
    required this.totalEmployees,
    required this.calendar,
  });

  factory LeaveApprovalClashCalendar.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalClashCalendar(
      totalEmployees: (json['totalEmployees'] as num?)?.toInt() ?? 0,
      calendar: (json['calendar'] as List? ?? const [])
          .map(
            (item) => LeaveApprovalClashDay.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class LeaveApprovalClashDay {
  final DateTime date;
  final int leaveCount;
  final double percentage;
  final String status;
  final List<LeaveApprovalClashDetail> leaveDetails;

  const LeaveApprovalClashDay({
    required this.date,
    required this.leaveCount,
    required this.percentage,
    required this.status,
    required this.leaveDetails,
  });

  factory LeaveApprovalClashDay.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalClashDay(
      date: DateTime.parse(json['date'] as String),
      leaveCount: (json['leaveCount'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? '',
      leaveDetails: (json['leaveDetails'] as List? ?? const [])
          .map(
            (item) => LeaveApprovalClashDetail.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class LeaveApprovalClashDetail {
  final int employeeId;
  final String employeeName;
  final String leaveType;
  final String reason;

  const LeaveApprovalClashDetail({
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.reason,
  });

  factory LeaveApprovalClashDetail.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalClashDetail(
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      employeeName: json['employeeName'] as String? ?? 'Unknown',
      leaveType: json['leaveType'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}
