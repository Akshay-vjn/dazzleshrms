class BreakHistoryResponse {
  final int status;
  final bool error;
  final String message;
  final BreakHistoryData data;

  BreakHistoryResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory BreakHistoryResponse.fromJson(Map<String, dynamic> json) {
    return BreakHistoryResponse(
      status: json['status'] as int? ?? 0,
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: BreakHistoryData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class BreakHistoryData {
  final List<BreakHistoryItem> breaks;
  final int totalBreakMinutes;

  BreakHistoryData({required this.breaks, required this.totalBreakMinutes});

  factory BreakHistoryData.fromJson(Map<String, dynamic> json) {
    return BreakHistoryData(
      breaks: (json['breaks'] as List<dynamic>? ?? [])
          .map((e) => BreakHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalBreakMinutes: json['totalBreakMinutes'] as int? ?? 0,
    );
  }
}

class BreakHistoryItem {
  final int employeeBreakId;
  final int employeeId;
  final String date;
  final DateTime? breakOutTime;
  final DateTime? breakInTime;
  final int totalMinutes;

  BreakHistoryItem({
    required this.employeeBreakId,
    required this.employeeId,
    required this.date,
    required this.breakOutTime,
    required this.breakInTime,
    required this.totalMinutes,
  });

  factory BreakHistoryItem.fromJson(Map<String, dynamic> json) {
    return BreakHistoryItem(
      employeeBreakId: json['employeeBreakId'] as int? ?? 0,
      employeeId: json['employeeId'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      breakOutTime: DateTime.tryParse(json['breakOutTime'] as String? ?? ''),
      breakInTime: DateTime.tryParse(json['breakInTime'] as String? ?? ''),
      totalMinutes: json['totalMinutes'] as int? ?? 0,
    );
  }
}
