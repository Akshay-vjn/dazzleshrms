import 'package:dazzleshrms/features/leave/widgets/balance_box.dart';
import 'package:flutter/material.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';

import 'apply_leave_bottomsheet.dart';

class ApplyLeaveScreen extends StatelessWidget {
  const ApplyLeaveScreen({super.key});

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
        "type": "Casual Leave",
        "from": "18 Apr 2025",
        "to": "18 Apr 2025",
        "status": "Approved",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave"),
      ),

      // ➕ ADD LEAVE BUTTON
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          backgroundColor: AppTheme.PrimaryColor,
          child: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              enableDrag: true, // production apps allow this
              backgroundColor: Colors.transparent,
              builder: (_) => const ApplyLeaveFormSheet(),
            );
          },
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= LEAVE BALANCE =================
          Center(
            child: Text(
              "Leave Balance",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: const [
              BalanceBox(label: "Total", value: "24"),
              SizedBox(width: 12),
              BalanceBox(label: "Used", value: "10"),
              SizedBox(width: 12),
              BalanceBox(label: "Balance", value: "14"),
            ],
          ),

          const SizedBox(height: 20),

          Divider(
            thickness: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),

          const SizedBox(height: 12),

          // ================= HISTORY =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔹 LEFT TITLE
              Text(
                "Leaves Applied",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  // 🔥 logic later
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: "Show All",
                    child: Text("Show All"),
                  ),
                  PopupMenuItem(
                    value: "Filter by Date",
                    child: Text("Filter by Date"),
                  ),
                ],
                child: TextButton.icon(
                  onPressed: null, // handled by PopupMenuButton
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 25,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  label: Text(
                    "Show All",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).textTheme.titleMedium?.color,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),

              ),


              // 🔹 RIGHT FILTER DROPDOWN
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            thickness: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leaveHistory.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final leave = leaveHistory[index];
              final status = leave["status"];

              final statusColor = switch (status) {
                "Approved" => AppTheme.statusSuccess,
                "Pending" => AppTheme.statusWarning,
                "Rejected" => AppTheme.statusError,
                _ => Theme.of(context).colorScheme.outline,
              };

              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                      Theme.of(context).shadowColor.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              leave["type"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline,
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
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
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
        ],
      ),
    );
  }
}
