class BreakStatusResponse {
  final int status;
  final bool error;
  final String message;
  final BreakStatusData data;

  BreakStatusResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory BreakStatusResponse.fromJson(Map<String, dynamic> json) {
    return BreakStatusResponse(
      status: json['status'] as int,
      error: json['error'] as bool,
      message: json['message'] as String,
      data: BreakStatusData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class BreakStatusData {
  final bool isOnBreak;
  final String currentAction;

  BreakStatusData({
    required this.isOnBreak,
    required this.currentAction,
  });

  factory BreakStatusData.fromJson(Map<String, dynamic> json) {
    return BreakStatusData(
      isOnBreak: json['isOnBreak'] as bool? ?? false,
      currentAction: json['currentAction'] as String? ?? 'BREAK_OUT',
    );
  }
}
