class EmployeeDashboardSummaryResponse {
  final int status;
  final bool error;
  final String message;
  final EmployeeDashboardSummaryData data;

  EmployeeDashboardSummaryResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EmployeeDashboardSummaryResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardSummaryResponse(
      status: _asInt(json['status']),
      error: json['error'] == true,
      message: json['message']?.toString() ?? '',
      data: EmployeeDashboardSummaryData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class EmployeeDashboardSummaryData {
  final EmployeeDashboardEmployee employee;
  final EmployeeDashboardPeriod period;
  final EmployeeDashboardShift shift;
  final EmployeeDashboardAttendance attendance;
  final EmployeeDashboardBreaks breaks;

  EmployeeDashboardSummaryData({
    required this.employee,
    required this.period,
    required this.shift,
    required this.attendance,
    required this.breaks,
  });

  factory EmployeeDashboardSummaryData.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardSummaryData(
      employee: EmployeeDashboardEmployee.fromJson(
        json['employee'] as Map<String, dynamic>? ?? {},
      ),
      period: EmployeeDashboardPeriod.fromJson(
        json['period'] as Map<String, dynamic>? ?? {},
      ),
      shift: EmployeeDashboardShift.fromJson(
        json['shift'] as Map<String, dynamic>? ?? {},
      ),
      attendance: EmployeeDashboardAttendance.fromJson(
        json['attendance'] as Map<String, dynamic>? ?? {},
      ),
      breaks: EmployeeDashboardBreaks.fromJson(
        json['breaks'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class EmployeeDashboardEmployee {
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String employeeDesignation;
  final int storeId;
  final String profileImage;

  EmployeeDashboardEmployee({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.employeeDesignation,
    required this.storeId,
    this.profileImage = '',
  });

  factory EmployeeDashboardEmployee.fromJson(Map<String, dynamic> json) {
    final image = json['profileImage'] ??
        json['profile_image'] ??
        json['employeeImage'] ??
        json['image'];
    final raw = image?.toString().trim() ?? '';
    return EmployeeDashboardEmployee(
      employeeId: _asInt(json['employeeId']),
      employeeName: json['employeeName']?.toString() ?? '',
      employeeCode: json['employeeCode']?.toString() ?? '',
      employeeDesignation: json['employeeDesignation']?.toString() ?? '',
      storeId: _asInt(json['storeId']),
      profileImage: (raw.isEmpty || raw.toLowerCase() == 'null') ? '' : raw,
    );
  }
}

class EmployeeDashboardPeriod {
  final String fromDate;
  final String toDate;

  EmployeeDashboardPeriod({
    required this.fromDate,
    required this.toDate,
  });

  factory EmployeeDashboardPeriod.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardPeriod(
      fromDate: json['fromDate']?.toString() ?? '',
      toDate: json['toDate']?.toString() ?? '',
    );
  }
}

class EmployeeDashboardShift {
  final String fromTime;
  final String toTime;
  final int shiftDurationMinutes;
  final String shiftDuration;

  EmployeeDashboardShift({
    required this.fromTime,
    required this.toTime,
    required this.shiftDurationMinutes,
    required this.shiftDuration,
  });

  factory EmployeeDashboardShift.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardShift(
      fromTime: json['fromTime']?.toString() ?? '',
      toTime: json['toTime']?.toString() ?? '',
      shiftDurationMinutes: _asInt(json['shiftDurationMinutes']),
      shiftDuration: json['shiftDuration']?.toString() ?? '',
    );
  }
}

class EmployeeDashboardAttendance {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int leaveDays;
  final int halfDays;
  final double attendancePercentage;
  final String averageCheckin;
  final String averageCheckout;
  final int averageWorkingMinutes;
  final String averageWorkingHours;

  EmployeeDashboardAttendance({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.leaveDays,
    required this.halfDays,
    required this.attendancePercentage,
    required this.averageCheckin,
    required this.averageCheckout,
    required this.averageWorkingMinutes,
    required this.averageWorkingHours,
  });

  factory EmployeeDashboardAttendance.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardAttendance(
      totalDays: _asInt(json['totalDays']),
      presentDays: _asInt(json['presentDays']),
      absentDays: _asInt(json['absentDays']),
      leaveDays: _asInt(json['leaveDays']),
      halfDays: _asInt(json['halfDays']),
      attendancePercentage: _asDouble(json['attendancePercentage']),
      averageCheckin: json['averageCheckin']?.toString() ?? '',
      averageCheckout: json['averageCheckout']?.toString() ?? '',
      averageWorkingMinutes: _asInt(json['averageWorkingMinutes']),
      averageWorkingHours: json['averageWorkingHours']?.toString() ?? '',
    );
  }
}

class EmployeeDashboardBreaks {
  final int averageBreak1Minutes;
  final String averageBreak1;
  final int averageBreak2Minutes;
  final String averageBreak2;
  final int averageBreak3Minutes;
  final String averageBreak3;
  final int averageBreak4PlusMinutes;
  final String averageBreak4Plus;
  final int averageTotalBreakMinutes;
  final String averageTotalBreak;
  final double averageBreaksPerDay;
  final int longestBreakMinutes;
  final String longestBreak;
  final int totalBreaks;

  EmployeeDashboardBreaks({
    required this.averageBreak1Minutes,
    required this.averageBreak1,
    required this.averageBreak2Minutes,
    required this.averageBreak2,
    required this.averageBreak3Minutes,
    required this.averageBreak3,
    required this.averageBreak4PlusMinutes,
    required this.averageBreak4Plus,
    required this.averageTotalBreakMinutes,
    required this.averageTotalBreak,
    required this.averageBreaksPerDay,
    required this.longestBreakMinutes,
    required this.longestBreak,
    required this.totalBreaks,
  });

  factory EmployeeDashboardBreaks.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardBreaks(
      averageBreak1Minutes: _asInt(json['averageBreak1Minutes']),
      averageBreak1: json['averageBreak1']?.toString() ?? '',
      averageBreak2Minutes: _asInt(json['averageBreak2Minutes']),
      averageBreak2: json['averageBreak2']?.toString() ?? '',
      averageBreak3Minutes: _asInt(json['averageBreak3Minutes']),
      averageBreak3: json['averageBreak3']?.toString() ?? '',
      averageBreak4PlusMinutes: _asInt(json['averageBreak4PlusMinutes']),
      averageBreak4Plus: json['averageBreak4Plus']?.toString() ?? '',
      averageTotalBreakMinutes: _asInt(json['averageTotalBreakMinutes']),
      averageTotalBreak: json['averageTotalBreak']?.toString() ?? '',
      averageBreaksPerDay: _asDouble(json['averageBreaksPerDay']),
      longestBreakMinutes: _asInt(json['longestBreakMinutes']),
      longestBreak: json['longestBreak']?.toString() ?? '',
      totalBreaks: _asInt(json['totalBreaks']),
    );
  }
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

double _asDouble(dynamic value) =>
    double.tryParse(value?.toString() ?? '') ?? 0;
