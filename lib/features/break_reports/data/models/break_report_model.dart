class BreakReportResponse {
  final int status;
  final bool error;
  final String message;
  final BreakReportData data;

  BreakReportResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory BreakReportResponse.fromJson(Map<String, dynamic> json) {
    return BreakReportResponse(
      status: json['status'] as int? ?? 0,
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: BreakReportData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class BreakReportData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<BreakReportItem> records;

  BreakReportData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.records,
  });

  factory BreakReportData.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final List<BreakReportItem> recordsList = [];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map) {
          recordsList.add(BreakReportItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return BreakReportData(
      totalItems: int.tryParse(json['totalItems']?.toString() ?? '') ?? 0,
      totalPages: int.tryParse(json['totalPages']?.toString() ?? '') ?? 0,
      currentPage: int.tryParse(json['currentPage']?.toString() ?? '') ?? 0,
      records: recordsList,
    );
  }
}

class BreakReportItem {
  final int employeeBreakId;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String profileImage;
  final String date;
  final String breakType;
  final String breakOutTime;
  final String breakInTime;
  final int totalMinutes;
  final String durationText;
  final String breakStatus;

  int breakIndex;

  BreakReportItem({
    required this.employeeBreakId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.profileImage,
    required this.date,
    required this.breakType,
    required this.breakOutTime,
    required this.breakInTime,
    required this.totalMinutes,
    this.durationText = '',
    required this.breakStatus,
    this.breakIndex = 0,
  });

  factory BreakReportItem.fromJson(Map<String, dynamic> json) {
    final rawBreakType = json['breakType']?.toString() ?? '';
    final explicitIndex = int.tryParse(json['breakIndex']?.toString() ?? '');
    int index = explicitIndex ?? 0;
    if (index == 0 && rawBreakType.isNotEmpty) {
      final match = RegExp(r'\d+').firstMatch(rawBreakType);
      if (match != null) {
        index = int.tryParse(match.group(0)!) ?? 0;
      }
    }

    final rawMinutes = json['totalMinutes'];
    final parsedMinutes = _parseMinutes(rawMinutes);
    final text = rawMinutes != null && rawMinutes is String && rawMinutes.trim().isNotEmpty
        ? rawMinutes.trim()
        : (parsedMinutes > 0 ? '$parsedMinutes min' : '0 min');

    return BreakReportItem(
      employeeBreakId: int.tryParse(json['employeeBreakId']?.toString() ?? '') ?? 0,
      employeeId: int.tryParse(json['employeeId']?.toString() ?? '') ?? 0,
      employeeName: json['employeeName']?.toString() ?? '',
      employeeCode: json['employeeCode']?.toString() ?? '',
      profileImage: json['profileImage']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      breakType: rawBreakType,
      breakOutTime: json['breakOutTime']?.toString() ?? '',
      breakInTime: json['breakInTime']?.toString() ?? '',
      totalMinutes: parsedMinutes,
      durationText: text,
      breakStatus: json['breakStatus']?.toString() ?? '',
      breakIndex: index,
    );
  }

  static int _parseMinutes(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    final str = value.toString().trim();
    if (str.isEmpty) return 0;

    final pureNumber = int.tryParse(str);
    if (pureNumber != null) return pureNumber;

    int hours = 0;
    int minutes = 0;

    final hrMatch =
        RegExp(r'(\d+)\s*(?:hr|hour)s?', caseSensitive: false).firstMatch(str);
    if (hrMatch != null) {
      hours = int.tryParse(hrMatch.group(1)!) ?? 0;
    }

    final minMatch =
        RegExp(r'(\d+)\s*(?:min|minute)s?', caseSensitive: false).firstMatch(str);
    if (minMatch != null) {
      minutes = int.tryParse(minMatch.group(1)!) ?? 0;
    }

    if (hrMatch == null && minMatch == null) {
      final anyNum = RegExp(r'\d+').firstMatch(str);
      if (anyNum != null) {
        return int.tryParse(anyNum.group(0)!) ?? 0;
      }
    }

    return (hours * 60) + minutes;
  }

  String get displayDuration =>
      durationText.isNotEmpty ? durationText : '$totalMinutes min';

  String get displayBreakName {
    if (breakIndex > 0) return 'Break $breakIndex';
    if (breakType.isNotEmpty) return breakType;
    return 'Break';
  }

  bool get isOverLimit {
    if (breakIndex >= 4) return true;
    if (breakIndex == 1 || breakIndex == 3) return totalMinutes > 15;
    if (breakIndex == 2) return totalMinutes > 30;
    final type = breakType.toUpperCase();
    if (type.contains('TEA') || type.contains('EVNG') || type.contains('EVENING')) {
      return totalMinutes > 15;
    }
    if (type.contains('LUNCH')) {
      return totalMinutes > 30;
    }
    return false;
  }

  bool get hasDurationColorRule {
    if (breakIndex > 0) return true;
    final type = breakType.toUpperCase();
    return type.contains('BREAK') ||
        type.contains('LUNCH') ||
        type.contains('TEA') ||
        type.contains('EVNG') ||
        type.contains('EVENING');
  }
}
