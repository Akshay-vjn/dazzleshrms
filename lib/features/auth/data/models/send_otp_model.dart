class SendOtpModel {
  final int status;
  final bool error;
  final String message;

  SendOtpModel({
    required this.status,
    required this.error,
    required this.message,
  });

  factory SendOtpModel.fromJson(Map<String, dynamic> json) {
    return SendOtpModel(
      status: json['status'] as int,
      error: json['error'] as bool,
      message: json['message'] as String,
    );
  }
}
