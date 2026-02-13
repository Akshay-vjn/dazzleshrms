class AttendanceQrResponse {
  final bool error;
  final String message;

  AttendanceQrResponse({
    required this.error,
    required this.message,
  });

  factory AttendanceQrResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceQrResponse(
      error: json['error'] as bool? ?? true,
      message: json['message'] as String? ?? '',
    );
  }
}
