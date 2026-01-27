class EmployeePendingLeaveResponse {
  final int status;
  final bool error;
  final String message;
  final EmployeePendingLeaveData data;

  EmployeePendingLeaveResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EmployeePendingLeaveResponse.fromJson(Map<String, dynamic> json) {
    return EmployeePendingLeaveResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      data: EmployeePendingLeaveData.fromJson(json['data']),
    );
  }
}

class EmployeePendingLeaveData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<EmployeePendingLeaveItem> records;

  EmployeePendingLeaveData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory EmployeePendingLeaveData.fromJson(Map<String, dynamic> json) {
    return EmployeePendingLeaveData(
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      records: (json['data'] as List?)
              ?.map((e) => EmployeePendingLeaveItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EmployeePendingLeaveItem {
  final int leaveRoasterId;
  final int employeeId;
  final String employeeName;
  final String empCode;
  final String fromDate;
  final String toDate;
  final String leaveType;
  final String store;
  final String designation;
  final String status;
  final String appliedAt;

  EmployeePendingLeaveItem({
    required this.leaveRoasterId,
    required this.employeeId,
    required this.employeeName,
    required this.empCode,
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    required this.store,
    required this.designation,
    required this.status,
    required this.appliedAt,
  });

  factory EmployeePendingLeaveItem.fromJson(Map<String, dynamic> json) {
    return EmployeePendingLeaveItem(
      leaveRoasterId: json['leaveRoasterId'] ?? 0,
      employeeId: json['employeeId'] ?? 0,
      employeeName: json['employeeName'] ?? '',
      empCode: json['empCode'] ?? '',
      fromDate: json['fromDate'] ?? '',
      toDate: json['toDate'] ?? '',
      leaveType: json['leaveType'] ?? '',
      store: json['store'] ?? '',
      designation: json['designation'] ?? '',
      status: json['status'] ?? '',
      appliedAt: json['appliedAt'] ?? '',
    );
  }
}
