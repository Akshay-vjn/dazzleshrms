class DashboardModel {
  final int status;
  final bool error;
  final String message;
  final DashboardData data;

  DashboardModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      status: json['status'] as int,
      error: json['error'] as bool,
      message: json['message'] as String,
      data: DashboardData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class DashboardData {
  final String name;
  final String role;
  final String store;
  final double totalLeaves;
  final double usedLeaves;
  final double availableLeaves;

  DashboardData({
    required this.name,
    required this.role,
    required this.store,
    required this.totalLeaves,
    required this.usedLeaves,
    required this.availableLeaves,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return DashboardData(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      store: json['store'] ?? '',
      totalLeaves: _parseDouble(json['totalLeaves']),
      usedLeaves: _parseDouble(json['usedLeaves']),
      availableLeaves: _parseDouble(json['availableLeaves']),
    );
  }
}


