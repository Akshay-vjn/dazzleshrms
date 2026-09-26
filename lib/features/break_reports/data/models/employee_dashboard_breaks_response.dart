class EmployeeDashboardBreaksResponse {
  final int status;
  final bool error;
  final String message;
  final EmployeeDashboardBreaksPage data;

  EmployeeDashboardBreaksResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EmployeeDashboardBreaksResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardBreaksResponse(
      status: _asInt(json['status']),
      error: json['error'] == true,
      message: json['message']?.toString() ?? '',
      data: EmployeeDashboardBreaksPage.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class EmployeeDashboardBreaksPage {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<EmployeeDashboardBreakDay> data;

  EmployeeDashboardBreaksPage({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.data,
  });

  factory EmployeeDashboardBreaksPage.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <EmployeeDashboardBreakDay>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(EmployeeDashboardBreakDay.fromJson(e));
        } else if (e is Map) {
          list.add(
            EmployeeDashboardBreakDay.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    return EmployeeDashboardBreaksPage(
      totalItems: _asInt(json['totalItems']),
      totalPages: _asInt(json['totalPages']),
      currentPage: _asInt(json['currentPage']) == 0
          ? 1
          : _asInt(json['currentPage']),
      data: list,
    );
  }
}

class EmployeeDashboardBreakDay {
  final String date;
  final List<EmployeeDashboardBreakItem> breaks;

  EmployeeDashboardBreakDay({
    required this.date,
    required this.breaks,
  });

  factory EmployeeDashboardBreakDay.fromJson(Map<String, dynamic> json) {
    final rawList = json['breaks'];
    final list = <EmployeeDashboardBreakItem>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(EmployeeDashboardBreakItem.fromJson(e));
        } else if (e is Map) {
          list.add(
            EmployeeDashboardBreakItem.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    list.sort((a, b) => a.breakNumber.compareTo(b.breakNumber));
    return EmployeeDashboardBreakDay(
      date: json['date']?.toString() ?? '',
      breaks: list,
    );
  }
}

class EmployeeDashboardBreakItem {
  final int breakId;
  final int breakNumber;
  final String? breakOutTime;
  final String? breakInTime;
  final String totalTime;
  final bool isActive;

  EmployeeDashboardBreakItem({
    required this.breakId,
    required this.breakNumber,
    required this.breakOutTime,
    required this.breakInTime,
    required this.totalTime,
    required this.isActive,
  });

  factory EmployeeDashboardBreakItem.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardBreakItem(
      breakId: _asInt(json['breakId']),
      breakNumber: _asInt(json['breakNumber']),
      breakOutTime: _asNullableString(json['breakOutTime']),
      breakInTime: _asNullableString(json['breakInTime']),
      totalTime: json['totalTime']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}
