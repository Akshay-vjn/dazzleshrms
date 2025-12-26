class RefreshTokenModel {
  final int status;
  final bool error;
  final String message;
  final RefreshTokenData data;

  RefreshTokenModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory RefreshTokenModel.fromJson(Map<String, dynamic> json) {
    return RefreshTokenModel(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      data: RefreshTokenData.fromJson(json['data']),
    );
  }
}

class RefreshTokenData {
  final String token;
  final String refreshToken;

  RefreshTokenData({
    required this.token,
    required this.refreshToken,
  });

  factory RefreshTokenData.fromJson(Map<String, dynamic> json) {
    return RefreshTokenData(
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }
}



