class Employee {
  final int employeeId;
  final String employeeCode;
  final String name;
  final String designation;
  final String store;

  Employee({
    required this.employeeId,
    required this.employeeCode,
    required this.name,
    required this.designation,
    required this.store,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employeeId'] ?? 0,
      employeeCode: json['employeeCode'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      store: json['store'] ?? '',
    );
  }
}

class EmployeeData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<Employee> data;

  EmployeeData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.data,
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => Employee.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EmployeeListResponse {
  final int status;
  final bool error;
  final String message;
  final EmployeeData data;

  EmployeeListResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EmployeeListResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeListResponse(
      status: json['status'] ?? 0,
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: EmployeeData.fromJson(json['data'] ?? {}),
    );
  }
}
