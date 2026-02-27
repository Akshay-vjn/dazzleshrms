class AttendanceQrResponse {
  final int status;
  final bool error;
  final String message;
  final QrData data;

  AttendanceQrResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory AttendanceQrResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceQrResponse(
      status: json['status'] as int,
      error: json['error'] as bool,
      message: json['message'] as String,
      data: QrData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class QrData {
  final String qrImage;
  final int qrSessionId;
  final int issuedAt;
  final int expiresAt;
  final int? sessionPin;

  QrData({
    required this.qrImage,
    required this.qrSessionId,
    required this.issuedAt,
    required this.expiresAt,
    this.sessionPin,
  });

  factory QrData.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['qrSessionId'] ?? json['qrId'];

    return QrData(
      qrImage: json['qrImage'] as String,
      qrSessionId: (idValue as num?)?.toInt() ?? 0,
      issuedAt: (json['issuedAt'] as num?)?.toInt() ?? 0,
      expiresAt: (json['expiresAt'] as num?)?.toInt() ?? 0,
      sessionPin: (json['sessionPin'] as num?)?.toInt(),
    );
  }

  int get remainingSeconds {
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = (expiresAt - now) / 1000;
    return remaining > 0 ? remaining.ceil() : 0;
  }
}