class DesignationResponse {
  final int status;
  final bool error;
  final String message;
  final List<Designation> data;

  DesignationResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory DesignationResponse.fromJson(Map<String, dynamic> json) {
    return DesignationResponse(
      status: json['status'] as int,
      error: json['error'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((e) => Designation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Designation {
  final int designationId;
  final String designation;

  Designation({
    required this.designationId,
    required this.designation,
  });

  factory Designation.fromJson(Map<String, dynamic> json) {
    return Designation(
      designationId: json['designationId'] as int,
      designation: json['designation'] as String,
    );
  }
}
