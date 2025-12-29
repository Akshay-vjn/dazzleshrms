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
    return DashboardData(
      name: json['name'],
      role: json['role'],
      store: json['store'],
      totalLeaves: (json['totalLeaves'] as num).toDouble(),
      usedLeaves: (json['usedLeaves'] as num).toDouble(),
      availableLeaves: (json['availableLeaves'] as num).toDouble(),

    );
  }
}


