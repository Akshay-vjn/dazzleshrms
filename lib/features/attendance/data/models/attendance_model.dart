class AttendanceApiResponse {
  final int status;
  final bool error;
  final String message;
  final AttendanceData data;

  AttendanceApiResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory AttendanceApiResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceApiResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      data: AttendanceData.fromJson(json['data']),
    );
  }
}

class AttendanceData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<AttendanceItem> records;
  final AttendanceSummary summary;

  AttendanceData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
    required this.summary,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      records: (json['data'] as List)
          .map((e) => AttendanceItem.fromJson(e))
          .toList(),
      summary: AttendanceSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class AttendanceSummary {
  final String month;
  final Map<String, int> counts;

  AttendanceSummary({
    required this.month,
    required this.counts,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    final rawCounts = json['counts'] as Map<String, dynamic>? ?? {};
    return AttendanceSummary(
      month: json['month']?.toString() ?? '',
      counts: rawCounts.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      ),
    );
  }
}

class AttendanceItem {
  final String date;
  final String status;

  AttendanceItem({
    required this.date,
    required this.status,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      date: json['date'],
      status: json['attendanceDescription'],
    );
  }
}
