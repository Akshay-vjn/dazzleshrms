class RejectChangeResponse {
  final int status;
  final bool error;
  final String message;

  RejectChangeResponse({
    required this.status,
    required this.error,
    required this.message,
  });

  factory RejectChangeResponse.fromJson(Map<String, dynamic> json) {
    return RejectChangeResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
    );
  }
}
