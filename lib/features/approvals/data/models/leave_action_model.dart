// leave_action_response.dart

class LeaveActionResponse {
  final bool success;
  final String message;
  final String newStatus;

  LeaveActionResponse({
    required this.success,
    required this.message,
    required this.newStatus,
  });

  factory LeaveActionResponse.fromJson(Map<String, dynamic> json) {
    return LeaveActionResponse(
      success: json['data']['success'],
      message: json['data']['message'],
      newStatus: json['data']['newStatus'],
    );
  }
}
