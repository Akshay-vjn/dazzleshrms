import 'package:flutter/material.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';

class LeaveHistoryScreen extends StatelessWidget {
  const LeaveHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaveHistory = [
      {
        "type": "Casual Leave",
        "from": "10 Jun 2025",
        "to": "12 Jun 2025",
        "status": "Approved",
      },
      {
        "type": "Sick Leave",
        "from": "02 May 2025",
        "to": "02 May 2025",
        "status": "Approved",
      },
      {
        "type": "Casual Leave  ",
        "from": "18 Apr 2025",
        "to": "18 Apr 2025",
        "status": "Approved",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave History"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: leaveHistory.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final leave = leaveHistory[index];
          final status = leave["status"];

          final statusColor = switch (status) {
            "Approved" => AppTheme.PrimaryColor,
            "Pending" => AppTheme.SecondaryColor,
            "Rejected" => AppTheme.statusError,
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
                // Status strip
                Container(
                  width: 6,
                  height: 80,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Leave Type
                        Text(
                          leave["type"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Date Range
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${leave["from"]} → ${leave["to"]}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.8),
                              ),
                            ),

                          ],
                        ),

                      ],
                    ),
                  ),
                ),

                // Status Text
                Padding(
                  padding: const EdgeInsets.only(
                    right: 16,
                    left: 8,
                  ),
                  child: Text(
                    status!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
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
