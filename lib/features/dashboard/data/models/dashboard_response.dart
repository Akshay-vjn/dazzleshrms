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
  final int totalLeaves;
  final int usedLeaves;
  final int availableLeaves;

  DashboardData({
    required this.name,
    required this.role,
    required this.store,
    required this.totalLeaves,
    required this.usedLeaves,
    required this.availableLeaves,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value) =>
        int.tryParse(value?.toString() ?? '') ?? 0;

    return DashboardData(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      store: json['store'] as String? ?? '',
      totalLeaves: _parseInt(json['totalLeaves']),
      usedLeaves: _parseInt(json['usedLeaves']),
      availableLeaves: _parseInt(json['availableLeaves']),
    );
  }
}


