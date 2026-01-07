class Store {
  final int storeId;
  final String storeName;

  Store({
    required this.storeId,
    required this.storeName,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['storeId'],
      storeName: json['storeName'],
    );
  }
}

class StoreResponse {
  final List<Store> data;
  final String message;
  final bool error;

  StoreResponse({
    required this.data,
    required this.message,
    required this.error,
  });

  factory StoreResponse.fromJson(Map<String, dynamic> json) {
    return StoreResponse(
      data: (json['data'] as List).map((e) => Store.fromJson(e)).toList(),
      message: json['message'],
      error: json['error'],
    );
  }
}
