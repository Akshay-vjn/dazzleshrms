class LeaveClashCalendarDay {
  final DateTime date;
  final int leaveCount;
  final double percentage;
  final String status;
  final List<LeaveClashLeaveDetail> leaveDetails;

  const LeaveClashCalendarDay({
    required this.date,
    required this.leaveCount,
    required this.percentage,
    required this.status,
    required this.leaveDetails,
  });

  factory LeaveClashCalendarDay.fromJson(Map<String, dynamic> json) {
    return LeaveClashCalendarDay(
      date: DateTime.parse(json['date'] as String),
      leaveCount: (json['leaveCount'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? '',
      leaveDetails: (json['leaveDetails'] as List? ?? const [])
          .map(
            (item) =>
                LeaveClashLeaveDetail.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class LeaveClashLeaveDetail {
  final int employeeId;
  final String employeeName;

  const LeaveClashLeaveDetail({
    required this.employeeId,
    required this.employeeName,
  });

  factory LeaveClashLeaveDetail.fromJson(Map<String, dynamic> json) {
    return LeaveClashLeaveDetail(
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      employeeName: json['employeeName'] as String? ?? 'Unknown employee',
    );
  }
}
