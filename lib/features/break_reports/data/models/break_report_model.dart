class BreakReportResponse {
  final int status;
  final bool error;
  final String message;
  final BreakReportData data;

  BreakReportResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory BreakReportResponse.fromJson(Map<String, dynamic> json) {
    return BreakReportResponse(
      status: json['status'] as int? ?? 0,
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: BreakReportData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class BreakReportData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<BreakReportItem> records;

  BreakReportData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory BreakReportData.fromJson(Map<String, dynamic> json) {
    return BreakReportData(
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
      records: (json['data'] as List<dynamic>? ?? [])
          .map((e) => BreakReportItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BreakReportItem {
  final int employeeBreakId;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String profileImage;
  final String date;
  final String breakType;
  final String breakOutTime;
  final String breakInTime;
  final int totalMinutes;
  final String breakStatus;

  BreakReportItem({
    required this.employeeBreakId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.profileImage,
    required this.date,
    required this.breakType,
    required this.breakOutTime,
    required this.breakInTime,
    required this.totalMinutes,
    required this.breakStatus,
  });

  factory BreakReportItem.fromJson(Map<String, dynamic> json) {
    return BreakReportItem(
      employeeBreakId: json['employeeBreakId'] as int? ?? 0,
      employeeId: json['employeeId'] as int? ?? 0,
      employeeName: json['employeeName'] as String? ?? '',
      employeeCode: json['employeeCode'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      date: json['date'] as String? ?? '',
      breakType: json['breakType'] as String? ?? '',
      breakOutTime: json['breakOutTime'] as String? ?? '',
      breakInTime: json['breakInTime'] as String? ?? '',
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      breakStatus: json['breakStatus'] as String? ?? '',
    );
  }

  bool get isOverLimit {
    final type = breakType.toUpperCase();
    if (type == 'TEA' || type == 'EVNG') {
      return totalMinutes > 15;
    }
    if (type == 'LUNCH') {
      return totalMinutes > 30;
    }
    return false;
  }

  bool get hasDurationColorRule {
    final type = breakType.toUpperCase();
    return type == 'TEA' || type == 'EVNG' || type == 'LUNCH';
  }
}
