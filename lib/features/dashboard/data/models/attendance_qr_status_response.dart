class AttendanceQrStatusResponse {
  final int status;
  final bool error;
  final String message;
  final AttendanceQrStatusData data;

  AttendanceQrStatusResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory AttendanceQrStatusResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceQrStatusResponse(
      status: json['status'] as int,
      error: json['error'] as bool,
      message: json['message'] as String,
      data: AttendanceQrStatusData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class AttendanceQrStatusData {
  final int qrId;
  final String status;

  AttendanceQrStatusData({
    required this.qrId,
    required this.status,
  });

  factory AttendanceQrStatusData.fromJson(Map<String, dynamic> json) {
    return AttendanceQrStatusData(
      qrId: json['qrId'] as int,
      status: json['status'] as String,
    );
  }
}

