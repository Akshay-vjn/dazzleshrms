class EmployeeAttendance {
  final String date;
  final String attendanceDescription;

  EmployeeAttendance({
    required this.date,
    required this.attendanceDescription,
  });

  factory EmployeeAttendance.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendance(
      date: json['date'] ?? '',
      attendanceDescription: json['attendanceDescription'] ?? '',
    );
  }
}

class EmployeeAttendanceSummary {
  final String month;
  final Map<String, int> counts;

  EmployeeAttendanceSummary({
    required this.month,
    required this.counts,
  });

  factory EmployeeAttendanceSummary.fromJson(Map<String, dynamic> json) {
    final rawCounts = json['counts'];
    final Map<String, int> parsedCounts = {};
    if (rawCounts is Map) {
      for (final entry in rawCounts.entries) {
        final key = entry.key?.toString() ?? '';
        final value = entry.value;
        if (key.isEmpty) continue;
        if (value is int) {
          parsedCounts[key] = value;
        } else if (value is num) {
          parsedCounts[key] = value.toInt();
        } else {
          final asInt = int.tryParse(value?.toString() ?? '');
          if (asInt != null) parsedCounts[key] = asInt;
        }
      }
    }

    return EmployeeAttendanceSummary(
      month: (json['month'] ?? '').toString(),
      counts: parsedCounts,
    );
  }
}

class EmployeeAttendanceData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<EmployeeAttendance> data;
  final EmployeeAttendanceSummary summary;

  EmployeeAttendanceData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.data,
    required this.summary,
  });

  factory EmployeeAttendanceData.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendanceData(
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => EmployeeAttendance.fromJson(e))
              .toList() ??
          [],
      summary: EmployeeAttendanceSummary.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class EmployeeAttendanceResponse {
  final int status;
  final bool error;
  final String message;
  final EmployeeAttendanceData data;

  EmployeeAttendanceResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EmployeeAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendanceResponse(
      status: json['status'] ?? 0,
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: EmployeeAttendanceData.fromJson(json['data'] ?? {}),
    );
  }
}
