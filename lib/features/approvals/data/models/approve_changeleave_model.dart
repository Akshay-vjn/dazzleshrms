class ApproveChangeResponse {
  final int status;
  final bool error;
  final String message;

  ApproveChangeResponse({
    required this.status,
    required this.error,
    required this.message,
  });

  factory ApproveChangeResponse.fromJson(Map<String, dynamic> json) {
    return ApproveChangeResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
    );
  }
}
