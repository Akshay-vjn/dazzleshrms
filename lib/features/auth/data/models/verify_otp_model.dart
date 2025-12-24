class VerifyOtpModel {
  final int status;
  final bool error;
  final String message;
  final VerifyOtpData data;

  VerifyOtpModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpModel(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      data: VerifyOtpData.fromJson(json['data']),
    );
  }
}

class VerifyOtpData {
  final String token;
  final Employee employee;

  VerifyOtpData({
    required this.token,
    required this.employee,
  });

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      token: json['token'],
      employee: Employee.fromJson(json['employee']),
    );
  }
}

class Employee {
  final int employeeId;
  final String employeeName;
  final int storeId;

  Employee({
    required this.employeeId,
    required this.employeeName,
    required this.storeId,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      storeId: json['storeId'],
    );
  }
}
