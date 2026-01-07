class Employee {
  final int employeeId;
  final String employeeName;

  Employee({
    required this.employeeId,
    required this.employeeName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
    );
  }
}

class EmployeeResponse {
  final List<Employee> data;
  final String message;
  final bool error;

  EmployeeResponse({
    required this.data,
    required this.message,
    required this.error,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeResponse(
      data: (json['data'] as List).map((e) => Employee.fromJson(e)).toList(),
      message: json['message'],
      error: json['error'],
    );
  }
}
