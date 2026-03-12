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
      case "Partially Approved":
        return Colors.blue;
      case "Rejected":
        return AppTheme.statusError;
      case "Applied":
        return AppTheme.statusWarning;
      default:
        return Colors.grey;
    }
  }

  String formatLeave(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  void _showUsedLeavesDialog() {
    ref.invalidate(usedLeavesProvider);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 400),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Used Leaves",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(usedLeavesProvider);
                    return state.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Error: ${e.toString()}",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () {
                                ref.invalidate(usedLeavesProvider);
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                      data: (data) {
                        if (data.isEmpty) {
                          return Center(
                            child: Text(
                              "No used leaves found",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: data.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = data[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item.leaveType,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(item.date),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.statusError.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${formatLeave(item.daysTaken)} Day${item.daysTaken > 1 ? 's' : ''}",
                                  style: const TextStyle(
                                    color: AppTheme.statusError,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                      onTap: () => _showUsedLeavesDialog(),
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
                  final hasRejectInfo = (leave.rejectReason != null &&
                      leave.rejectReason!.trim().isNotEmpty) ||
                      leave.rejectedDates.isNotEmpty;
                  final isDark = Theme.of(context).brightness == Brightness.dark;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
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
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Leave type and status row
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  leave.leaveType,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                leave.status,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Date range
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 15,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.7),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "${leave.fromDate} → ${leave.toDate}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          if (hasRejectInfo) ...[
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (leave.rejectReason != null &&
                                    leave.rejectReason!.trim().isNotEmpty) ...[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: AppTheme.statusError,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          leave.rejectReason!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.statusError.withOpacity(0.9),
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (leave.rejectedDates.isNotEmpty) ...[
                                  if (leave.rejectReason != null &&
                                      leave.rejectReason!.trim().isNotEmpty)
                                    const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 14,
                                        color: AppTheme.statusError,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "Rejected: ${leave.rejectedDates.join(', ')}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.statusError.withOpacity(0.85),
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
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