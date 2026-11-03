class BreakHistoryResponse {
  final int status;
  final bool error;
  final String message;
  final BreakHistoryData data;

  BreakHistoryResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory BreakHistoryResponse.fromJson(Map<String, dynamic> json) {
    return BreakHistoryResponse(
      status: json['status'] as int? ?? 0,
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: BreakHistoryData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class BreakHistoryData {
  final List<BreakHistoryItem> breaks;
  final int totalBreakMinutes;

  BreakHistoryData({required this.breaks, required this.totalBreakMinutes});

  factory BreakHistoryData.fromJson(Map<String, dynamic> json) {
    return BreakHistoryData(
      breaks: (json['breaks'] as List<dynamic>? ?? [])
          .map((e) => BreakHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalBreakMinutes:
          int.tryParse(json['totalBreakMinutes']?.toString() ?? '') ?? 0,
    );
  }
}

class BreakHistoryItem {
  final int employeeBreakId;
  final int employeeId;
  final String date;
  final String breakType;
  final DateTime? breakOutTime;
  final DateTime? breakInTime;
  final int totalMinutes;
  final String breakStatus;

  BreakHistoryItem({
    required this.employeeBreakId,
    required this.employeeId,
    required this.date,
    required this.breakType,
    required this.breakOutTime,
    required this.breakInTime,
    required this.totalMinutes,
    required this.breakStatus,
  });

  factory BreakHistoryItem.fromJson(Map<String, dynamic> json) {
    final date = json['date']?.toString() ?? '';
    return BreakHistoryItem(
      employeeBreakId:
          int.tryParse(json['employeeBreakId']?.toString() ?? '') ?? 0,
      employeeId: int.tryParse(json['employeeId']?.toString() ?? '') ?? 0,
      date: date,
      breakType: json['breakType']?.toString() ?? '',
      breakOutTime: _parseBreakTime(json['breakOutTime'], date),
      breakInTime: _parseBreakTime(json['breakInTime'], date),
      totalMinutes: _parseBreakMinutes(json['totalMinutes']),
      breakStatus: json['breakStatus']?.toString() ?? '',
    );
  }

  String get displayBreakType => breakType.trim().isEmpty ? 'Break' : breakType;

  String get displayBreakStatus => breakStatus
      .trim()
      .replaceAll('_', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .toUpperCase();

  int get breakNumber {
    final match = RegExp(r'\d+').firstMatch(breakType);
    return int.tryParse(match?.group(0) ?? '') ?? 0;
  }

  bool get isOverLimit {
    if (breakNumber >= 4) return true;
    if (breakNumber == 1 || breakNumber == 3) return totalMinutes > 15;
    if (breakNumber == 2) return totalMinutes > 30;

    final type = breakType.toUpperCase();
    if (type.contains('LUNCH')) return totalMinutes > 30;
    if (type.contains('TEA') ||
        type.contains('EVNG') ||
        type.contains('EVENING')) {
      return totalMinutes > 15;
    }
    return false;
  }

  bool get hasDurationColorRule {
    if (breakNumber > 0) return true;
    final type = breakType.toUpperCase();
    return type.contains('BREAK') ||
        type.contains('LUNCH') ||
        type.contains('TEA') ||
        type.contains('EVNG') ||
        type.contains('EVENING');
  }
}

DateTime? _parseBreakTime(dynamic value, String date) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty || raw.toLowerCase() == 'null') return null;

  final parsedDateTime = DateTime.tryParse(raw);
  if (parsedDateTime != null) return parsedDateTime;

  final timeMatch = RegExp(
    r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$',
  ).firstMatch(raw);
  if (timeMatch == null) return null;

  final baseDate = DateTime.tryParse(date) ?? DateTime.now();
  var hour = int.tryParse(timeMatch.group(1)!) ?? 0;
  final minute = int.tryParse(timeMatch.group(2)!) ?? 0;
  final period = timeMatch.group(3)!.toUpperCase();
  if (period == 'PM' && hour < 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;

  return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
}

int _parseBreakMinutes(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();

  final raw = value.toString().trim();
  if (raw.isEmpty) return 0;
  final numeric = int.tryParse(raw);
  if (numeric != null) return numeric;

  final hours =
      int.tryParse(
        RegExp(
              r'(\d+)\s*(?:hr|hour)s?',
              caseSensitive: false,
            ).firstMatch(raw)?.group(1) ??
            '',
      ) ??
      0;
  final minutes =
      int.tryParse(
        RegExp(
              r'(\d+)\s*(?:min|minute)s?',
              caseSensitive: false,
            ).firstMatch(raw)?.group(1) ??
            '',
      ) ??
      0;
  return (hours * 60) + minutes;
}
