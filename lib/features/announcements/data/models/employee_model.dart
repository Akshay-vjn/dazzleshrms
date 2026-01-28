class Employee {
  final int employeeId;
  final String employeeName;

  Employee({
    required this.employeeId,
    required this.employeeName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      // Handle employeeId, employee_id, id, etc.
      employeeId: json['employeeId'] ?? json['employee_id'] ?? json['id'] ?? 0,
      // Handle employeeName, employee_name, name, etc.
      employeeName: json['employeeName'] ?? json['employee_name'] ?? json['name'] ?? '',
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
    // Handle both List and Map responses from different endpoints
    final dynamic rawData = json['data'];
    final List<Employee> employees;
    
    if (rawData is List) {
      // Normal case: data is a list of employees
      employees = rawData.map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList();
    } else if (rawData is Map<String, dynamic>) {
      // Check if it's a paginated response (where data contains another data list)
      if (rawData['data'] is List) {
        employees = (rawData['data'] as List)
            .map((e) => Employee.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // Edge case: data is a single employee object
        employees = [Employee.fromJson(rawData)];
      }
    } else {
      // Fallback: empty list
      employees = [];
    }
    
    return EmployeeResponse(
      data: employees,
      message: json['message'] ?? '',
      error: json['error'] ?? false,
    );
  }
}
