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

  AttendanceData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      records: (json['data'] as List)
          .map((e) => AttendanceItem.fromJson(e))
          .toList(),
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
