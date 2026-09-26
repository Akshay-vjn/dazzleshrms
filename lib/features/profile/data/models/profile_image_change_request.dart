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

  const ProfileImageRequestEmployee({
    required this.name,
    required this.code,
    required this.mobile,
    required this.profileImage,
  });

  factory ProfileImageRequestEmployee.fromJson(Map<String, dynamic> json) {
    return ProfileImageRequestEmployee(
      name: json['employeeName']?.toString() ?? '',
      code: json['employeeCode']?.toString() ?? '',
      mobile: json['employeeMobileNumber']?.toString() ?? '',
      profileImage: json['profileImage']?.toString() ?? '',
    );
  }
}
