import 'package:dazzleshrms/core/app_theme/app_page_bar.dart';
import 'package:dazzleshrms/core/app_theme/app_surface.dart';
import 'package:dazzleshrms/core/app_theme/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme/app_theme.dart';
import '../data/provider/employee_leave_provider.dart';
import '../data/models/employee_leave_model.dart';
import '../../leave/presentation/widgets/balance_box.dart';
import 'widgets/apply_employee_leave_bottomsheet.dart';

class EmployeeLeaveScreen extends ConsumerStatefulWidget {
  final int employeeId;
  final String employeeName;

  const EmployeeLeaveScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  ConsumerState<EmployeeLeaveScreen> createState() =>
      _EmployeeLeaveScreenState();
}

class _EmployeeLeaveScreenState extends ConsumerState<EmployeeLeaveScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 10;
  bool _isLoadingMore = false;
  final List<EmployeeLeaveRecord> _items = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    _items.clear();
    _currentPage = 1;
    await ref
        .read(employeeLeavesProvider(widget.employeeId).notifier)
        .loadLeaves(page: _currentPage, limit: _limit);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 120 &&
        !_isLoadingMore) {
      final state = ref.read(employeeLeavesProvider(widget.employeeId));
      state.whenOrNull(
        data: (data) {
          if (data == null) return;
          if (_currentPage < data.data.totalPages) {
            _loadNextPage();
          }
        },
      );
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await ref
        .read(employeeLeavesProvider(widget.employeeId).notifier)
        .loadLeaves(page: _currentPage, limit: _limit);
    if (mounted) setState(() => _isLoadingMore = false);
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  String _formatLeave(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  void _showUsedLeavesDialog() {
    ref.invalidate(usedLeavesFamilyProvider(widget.employeeId));

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                    final state = ref.watch(
                      usedLeavesFamilyProvider(widget.employeeId),
                    );
                    return state.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Error: ${e.toString()}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () {
                                ref.invalidate(
                                  usedLeavesFamilyProvider(widget.employeeId),
                                );
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
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: data.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = data[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item.leaveType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(item.date),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.statusError.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${_formatLeave(item.daysTaken)} Day${item.daysTaken > 1 ? 's' : ''}",
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
    final leaveState = ref.watch(employeeLeavesProvider(widget.employeeId));
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: AppPageBar(title: ''),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              enableDrag: true,
              backgroundColor: Colors.transparent,
              builder: (_) =>
                  ApplyEmployeeLeaveFormSheet(employeeId: widget.employeeId),
            );
          },
        ),
      ),

      body: leaveState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _onRefresh,
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
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: const Center(child: Text("No leave data")),
                ),
              ),
            );
          }

          for (final item in leaveData.data.data) {
            if (!_items.any((e) => e.leaveRoasterId == item.leaveRoasterId)) {
              _items.add(item);
            }
          }

          final summary = leaveData.data.summary;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 0,
                bottom: 16,
              ),
              children: [
                Center(
                  child: Text(
                    "Leave Balance",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    BalanceBox(
                      label: "Total",
                      value: _formatLeave(summary.totalLeaves),
                    ),
                    const SizedBox(width: 12),
                    BalanceBox(
                      label: "Used",
                      value: _formatLeave(summary.usedLeaves),
                      onTap: () => _showUsedLeavesDialog(),
                    ),
                    const SizedBox(width: 12),
                    BalanceBox(
                      label: "Balance",
                      value: _formatLeave(summary.availableLeaves),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Leaves Applied",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
                if (_items.isEmpty)
                  const Center(child: Text("No leaves applied")),
                ...List.generate(_items.length + (_isLoadingMore ? 1 : 0), (
                  index,
                ) {
                  if (index == _items.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final leave = _items[index];
                  final statusColor = _statusColor(leave.status);
                  final hasRejectInfo =
                      (leave.rejectReason != null &&
                          leave.rejectReason!.trim().isNotEmpty) ||
                      leave.rejectedDates.isNotEmpty;

                  return AppSurface(
                    margin: const EdgeInsets.only(bottom: 12),

                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 15,
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "${leave.fromDate} → ${leave.toDate}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.outline,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
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
                                            color: AppTheme.statusError
                                                .withValues(alpha: 0.9),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
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
                                            color: AppTheme.statusError
                                                .withValues(alpha: 0.85),
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
                }),
              ],
            ),
          );
        },
      ),
    );
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
