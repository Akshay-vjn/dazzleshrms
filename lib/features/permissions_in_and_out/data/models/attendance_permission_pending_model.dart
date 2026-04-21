class AttendancePermissionPendingResponse {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<AttendancePermissionPendingItem> items;

  const AttendancePermissionPendingResponse({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory AttendancePermissionPendingResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final rawItems = data['data'] as List<dynamic>? ?? <dynamic>[];

    return AttendancePermissionPendingResponse(
      totalItems: (data['totalItems'] as num?)?.toInt() ?? 0,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (data['currentPage'] as num?)?.toInt() ?? 1,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(AttendancePermissionPendingItem.fromJson)
          .toList(),
    );
  }
}

class AttendancePermissionPendingItem {
  final int permissionId;
  final int employeeId;
  final String date;
  final String type;
  final String? fromTime;
  final String? toTime;
  final int totalMinutes;
  final String reason;
  final String status;
  final String? employeeName;
  final String? storeName;
  final String? fromTimeFormatted;
  final String? toTimeFormatted;
  final String? durationText;

  const AttendancePermissionPendingItem({
    required this.permissionId,
    required this.employeeId,
    required this.date,
    required this.type,
    required this.fromTime,
    required this.toTime,
    required this.totalMinutes,
    required this.reason,
    required this.status,
    required this.employeeName,
    required this.storeName,
    required this.fromTimeFormatted,
    required this.toTimeFormatted,
    required this.durationText,
  });

  factory AttendancePermissionPendingItem.fromJson(Map<String, dynamic> json) {
    final employee = json['employee'] as Map<String, dynamic>?;
    final store = json['store'] as Map<String, dynamic>?;
    final fromTimeRaw = json['fromTime'] ?? json['appliedOutTime'];
    final toTimeRaw = json['toTime'] ?? json['appliedInTime'];
    final fromTimeFormattedRaw =
        json['fromTimeFormatted'] ?? json['appliedOutTimeFormatted'];
    final toTimeFormattedRaw =
        json['toTimeFormatted'] ?? json['appliedInTimeFormatted'];
    final totalMinutesRaw = json['totalMinutes'];

    return AttendancePermissionPendingItem(
      permissionId: ((json['attendancePermissionId'] ??
                      json['employeePermissionId']) as num?)
                  ?.toInt() ??
              0,
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      date: (json['date'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      fromTime: fromTimeRaw?.toString(),
      toTime: toTimeRaw?.toString(),
      totalMinutes: (totalMinutesRaw as num?)?.toInt() ?? 0,
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      employeeName: employee?['employeeName']?.toString(),
      storeName: store?['storeName']?.toString(),
      fromTimeFormatted: fromTimeFormattedRaw?.toString(),
      toTimeFormatted: toTimeFormattedRaw?.toString(),
      durationText: json['durationText']?.toString(),
    );
  }

  bool get isLateEntry => type.toUpperCase() == 'LATE_ENTRY';
  String get typeLabel => isLateEntry ? 'Late Entry' : 'Early Exit';
}
