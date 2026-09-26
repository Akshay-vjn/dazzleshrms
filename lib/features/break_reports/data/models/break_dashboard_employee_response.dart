class BreakDashboardEmployeeResponse {
  final int status;
  final bool error;
  final String message;
  final BreakDashboardEmployeeData data;

  BreakDashboardEmployeeResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory BreakDashboardEmployeeResponse.fromJson(Map<String, dynamic> json) {
    return BreakDashboardEmployeeResponse(
      status: json['status'] as int? ?? 0,
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: BreakDashboardEmployeeData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class BreakDashboardEmployeeData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<BreakDashboardEmployeeItem> data;

  BreakDashboardEmployeeData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.data,
  });

  factory BreakDashboardEmployeeData.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final List<BreakDashboardEmployeeItem> list = [];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(BreakDashboardEmployeeItem.fromJson(e));
        } else if (e is Map) {
          list.add(BreakDashboardEmployeeItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return BreakDashboardEmployeeData(
      totalItems: int.tryParse(json['totalItems']?.toString() ?? '') ?? 0,
      totalPages: int.tryParse(json['totalPages']?.toString() ?? '') ?? 0,
      currentPage: int.tryParse(json['currentPage']?.toString() ?? '') ?? 1,
      data: list,
    );
  }
}

class BreakDashboardEmployeeItem {
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String employeeDesignation;
  final String profileImage;

  BreakDashboardEmployeeItem({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.employeeDesignation,
    this.profileImage = '',
  });

  factory BreakDashboardEmployeeItem.fromJson(Map<String, dynamic> json) {
    return BreakDashboardEmployeeItem(
      employeeId: int.tryParse(json['employeeId']?.toString() ?? '') ?? 0,
      employeeName: json['employeeName']?.toString() ?? '',
      employeeCode: json['employeeCode']?.toString() ?? '',
      employeeDesignation: json['employeeDesignation']?.toString() ?? '',
      profileImage: _readProfileImage(json),
    );
  }
}

String _readProfileImage(Map<String, dynamic> json) {
  final value = json['profileImage'] ??
      json['profile_image'] ??
      json['employeeImage'] ??
      json['image'];
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty || raw.toLowerCase() == 'null') return '';
  return raw;
}
