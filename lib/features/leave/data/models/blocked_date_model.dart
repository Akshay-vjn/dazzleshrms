class BlockedDateModel {
  final int dateId;
  final DateTime date;
  final String reason;

  BlockedDateModel({
    required this.dateId,
    required this.date,
    required this.reason,
  });

  factory BlockedDateModel.fromJson(Map<String, dynamic> json) {
    return BlockedDateModel(
      dateId: json['dateId'],
      date: DateTime.parse(json['date']),
      reason: json['reason'] ?? '',
    );
  }
}
