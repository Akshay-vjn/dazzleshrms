class ProfileImageChangeRequest {
  final int requestId;
  final int employeeId;
  final String status;
  final DateTime? requestedAt;
  final ProfileImageRequestEmployee employee;

  const ProfileImageChangeRequest({
    required this.requestId,
    required this.employeeId,
    required this.status,
    required this.requestedAt,
    required this.employee,
  });

  factory ProfileImageChangeRequest.fromJson(Map<String, dynamic> json) {
    return ProfileImageChangeRequest(
      requestId: (json['requestId'] as num?)?.toInt() ?? 0,
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      requestedAt: DateTime.tryParse(json['requestedAt']?.toString() ?? ''),
      employee: ProfileImageRequestEmployee.fromJson(
        json['employee'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class ProfileImageRequestEmployee {
  final String name;
  final String code;
  final String mobile;
  final String profileImage;
  final int? storeId;
  final String storeName;

  const ProfileImageRequestEmployee({
    required this.name,
    required this.code,
    required this.mobile,
    required this.profileImage,
    required this.storeId,
    required this.storeName,
  });

  factory ProfileImageRequestEmployee.fromJson(Map<String, dynamic> json) {
    final store = json['store'] is Map
        ? Map<String, dynamic>.from(json['store'] as Map)
        : const <String, dynamic>{};
    final rawStoreId = store['storeId'];

    return ProfileImageRequestEmployee(
      name: json['employeeName']?.toString() ?? '',
      code: json['employeeCode']?.toString() ?? '',
      mobile: json['employeeMobileNumber']?.toString() ?? '',
      profileImage: json['profileImage']?.toString() ?? '',
      storeId: rawStoreId is num
          ? rawStoreId.toInt()
          : int.tryParse(rawStoreId?.toString() ?? ''),
      storeName: store['storeName']?.toString() ?? '',
    );
  }
}
