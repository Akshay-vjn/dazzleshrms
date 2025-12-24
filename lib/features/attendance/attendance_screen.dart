import 'package:flutter/material.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  final List<Map<String, String>> attendanceData = const [
    {"date": "Dec 18, 2025", "status": "Present"},
    {"date": "Dec 17, 2025", "status": "Present"},
    {"date": "Dec 16, 2025", "status": "Absent"},
    {"date": "Dec 15, 2025", "status": "Present"},
    {"date": "Dec 14, 2025", "status": "Present"},
    {"date": "Dec 13, 2025", "status": "Absent"},
    {"date": "Dec 12, 2025", "status": "Present"},
    {"date": "Dec 11, 2025", "status": "Present"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: attendanceData.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = attendanceData[index];
          final status = item["status"]!;

          final statusColor = switch (status) {
            "Present" => Colors.green,
            "Absent" => Colors.red,
            _ => Theme.of(context).colorScheme.outline,
          };


          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // STATUS STRIP (same as leave history)
                Container(
                  width: 6,
                  height: 72,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // DATE
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item["date"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // STATUS TEXT
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
