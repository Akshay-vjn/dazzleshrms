class EmployeeDashboardAttendanceResponse {
  final int status;
  final bool error;
  final String message;
  final EmployeeDashboardAttendancePage data;

  EmployeeDashboardAttendanceResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EmployeeDashboardAttendanceResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmployeeDashboardAttendanceResponse(
      status: _asInt(json['status']),
      error: json['error'] == true,
      message: json['message']?.toString() ?? '',
      data: EmployeeDashboardAttendancePage.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class EmployeeDashboardAttendancePage {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<EmployeeDashboardAttendanceItem> data;

  EmployeeDashboardAttendancePage({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.data,
  });

  factory EmployeeDashboardAttendancePage.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <EmployeeDashboardAttendanceItem>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(EmployeeDashboardAttendanceItem.fromJson(e));
        } else if (e is Map) {
          list.add(
            EmployeeDashboardAttendanceItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          );
        }
      }
    }
    return EmployeeDashboardAttendancePage(
      totalItems: _asInt(json['totalItems']),
      totalPages: _asInt(json['totalPages']),
      currentPage: _asInt(json['currentPage']) == 0
          ? 1
          : _asInt(json['currentPage']),
      data: list,
    );
  }
}

class EmployeeDashboardAttendanceItem {
  final int attendanceId;
  final String date;
  final String? checkinTime;
  final String? checkoutTime;
  final String workingHours;
  final int attendanceTypeId;
  final String attendanceDescription;

  EmployeeDashboardAttendanceItem({
    required this.attendanceId,
    required this.date,
    required this.checkinTime,
    required this.checkoutTime,
    required this.workingHours,
    required this.attendanceTypeId,
    required this.attendanceDescription,
  });

  factory EmployeeDashboardAttendanceItem.fromJson(Map<String, dynamic> json) {
    final type = json['attendanceType'];
    Map<String, dynamic> typeMap = {};
    if (type is Map<String, dynamic>) {
      typeMap = type;
    } else if (type is Map) {
      typeMap = Map<String, dynamic>.from(type);
    }
    return EmployeeDashboardAttendanceItem(
      attendanceId: _asInt(json['attendanceId']),
      date: json['date']?.toString() ?? '',
      checkinTime: _asNullableString(json['checkinTime']),
      checkoutTime: _asNullableString(json['checkoutTime']),
      workingHours: json['workingHours']?.toString() ?? '',
      attendanceTypeId: _asInt(typeMap['attendanceId']),
      attendanceDescription:
          typeMap['attendanceDescription']?.toString() ?? '',
    );
  }
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}
