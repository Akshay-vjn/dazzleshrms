class StoreQrCheckinResponse {
  final bool error;
  final String message;

  StoreQrCheckinResponse({
    required this.error,
    required this.message,
  });

  factory StoreQrCheckinResponse.fromJson(Map<String, dynamic> json) {
    return StoreQrCheckinResponse(
      error: json['error'] as bool? ?? true,
      message: json['message'] as String? ?? '',
    );
  }
}
