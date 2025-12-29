class ChangeLeaveResponse {
  final int status;
  final bool error;
  final String message;
  final ChangeLeaveData data;

  ChangeLeaveResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory ChangeLeaveResponse.fromJson(Map<String, dynamic> json) {
    return ChangeLeaveResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      data: ChangeLeaveData.fromJson(json['data']),
    );
  }
}

class ChangeLeaveData {
  final int logId;
  final String status;
  final String source;
  final String fromDate;
  final String toDate;

  ChangeLeaveData({
    required this.logId,
    required this.status,
    required this.source,
    required this.fromDate,
    required this.toDate,
  });

  factory ChangeLeaveData.fromJson(Map<String, dynamic> json) {
    return ChangeLeaveData(
      logId: json['logId'],
      status: json['status'],
      source: json['source'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
    );
  }
}
