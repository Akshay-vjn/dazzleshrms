import 'package:dazzleshrms/features/leave/presentation/widgets/balance_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import '../apply_leave_bottomsheet.dart';
import '../data/providers/leave_provider.dart';

class ApplyLeaveScreen extends ConsumerStatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  ConsumerState<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends ConsumerState<ApplyLeaveScreen> {
  int _page = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    ref.read(leaveProvider.notifier).reset();
    _page = 1;

    await ref.read(leaveProvider.notifier).loadLeaves(
      page: _page,
      limit: _limit,
      forceRefresh: true,
    );
  }

  Future<void> _refresh() async {
    await _loadData();
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Approved":
        return AppTheme.statusSuccess;
      case "Rejected":
        return AppTheme.statusError;
      case "Applied":
        return AppTheme.statusWarning;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveState = ref.watch(leaveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave"),
      ),

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
              enableDrag: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const ApplyLeaveFormSheet(),
            );
          },
        ),
      ),

      body: leaveState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.toString(),
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refresh,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        data: (leaveData) {
          if (leaveData == null) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: const Center(child: Text("No leave data")),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
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
                  children: [
                    BalanceBox(
                      label: "Total",
                      value: leaveData.summary.totalLeaves.toString(),
                    ),
                    const SizedBox(width: 12),
                    BalanceBox(
                      label: "Used",
                      value: leaveData.summary.usedLeaves.toString(),
                    ),
                    const SizedBox(width: 12),
                    BalanceBox(
                      label: "Balance",
                      value: leaveData.summary.availableLeaves.toString(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Divider(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Leaves Applied",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // PopupMenuButton<String>(
                    //   itemBuilder: (_) => const [
                    //     PopupMenuItem(value: "all", child: Text("Show All")),
                    //     PopupMenuItem(
                    //         value: "date", child: Text("Filter by Date")),
                    //   ],
                    //   child: TextButton.icon(
                    //     onPressed: null,
                    //     icon: Icon(
                    //       Icons.keyboard_arrow_down_rounded,
                    //       color: Theme.of(context).textTheme.titleMedium?.color,
                    //     ),
                    //     label: Text(
                    //       "Show All",
                    //       style: Theme.of(context).textTheme.titleMedium,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
                const SizedBox(height: 12),

                if (leaveData.records.isEmpty)
                  const Center(child: Text("No leaves applied")),

                ...leaveData.records.map((leave) {
                  final color = _statusColor(leave.status);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .shadowColor
                              .withOpacity(0.08),
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
                            color: color,
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
                                  leave.leaveType,
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
                                      "${leave.fromDate} → ${leave.toDate}",
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
                            leave.status,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}