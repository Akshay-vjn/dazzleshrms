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

class EmployeeAttendanceData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<EmployeeAttendance> data;

  EmployeeAttendanceData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.data,
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
