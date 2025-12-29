class ChangedTabActionResponse {
  final int status;
  final bool error;
  final String message;

  ChangedTabActionResponse({
    required this.status,
    required this.error,
    required this.message,
  });

  factory ChangedTabActionResponse.fromJson(Map<String, dynamic> json) {
    return ChangedTabActionResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
    );
  }
}
