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
  ConsumerState<EmployeeLeaveScreen> createState() => _EmployeeLeaveScreenState();
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

  void _loadData() {
    _items.clear();
    _currentPage = 1;
    ref.read(employeeLeavesProvider(widget.employeeId).notifier).loadLeaves(
          page: _currentPage,
          limit: _limit,
        );
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
    _loadData();
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
                    final state = ref.watch(usedLeavesFamilyProvider(widget.employeeId));
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
                                ref.invalidate(usedLeavesFamilyProvider(widget.employeeId));
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
                          separatorBuilder: (_, ___) => const Divider(),
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
                                  color: AppTheme.statusError.withValues(alpha: 0.1),
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text("Leaves"),
      centerTitle: true,),
      
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
              builder: (_) => ApplyEmployeeLeaveFormSheet(employeeId: widget.employeeId),
            );
          },
        ),
      ),

      body: leaveState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString(), style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _onRefresh, child: const Text("Retry")),
            ],
          ),
        ),
        data: (leaveData) {
          if (leaveData == null) return const Center(child: Text("No records found"));

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
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Text(
                    "Leave Balance",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    BalanceBox(label: "Total", value: summary.totalLeaves.toStringAsFixed(0)),
                    const SizedBox(width: 12),
                    BalanceBox(
                      label: "Used", 
                      value: summary.usedLeaves.toStringAsFixed(0),
                      onTap: () => _showUsedLeavesDialog(),
                    ),
                    const SizedBox(width: 12),
                    BalanceBox(label: "Balance", value: summary.availableLeaves.toStringAsFixed(0)),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  "Leave History",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (_items.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text("No leaves found"),
                  )),
                ...List.generate(_items.length + (_isLoadingMore ? 1 : 0), (index) {
                  if (index == _items.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final leave = _items[index];
                  final statusColor = _statusColor(leave.status);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                leave.leaveType,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  leave.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_month, size: 14, color: theme.hintColor),
                              const SizedBox(width: 6),
                              Text(
                                "${leave.fromDate} → ${leave.toDate}",
                                style: TextStyle(color: theme.hintColor, fontSize: 13),
                              ),
                            ],
                          ),
                          if (leave.rejectReason != null || leave.rejectedDates.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.statusError.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (leave.rejectReason != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.error_outline, size: 14, color: AppTheme.statusError),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            leave.rejectReason!,
                                            style: const TextStyle(color: AppTheme.statusError, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (leave.rejectedDates.isNotEmpty) ...[
                                    if (leave.rejectReason != null) const SizedBox(height: 6),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.event_busy, size: 14, color: AppTheme.statusError),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "Rejected Dates: ${leave.rejectedDates.join(', ')}",
                                            style: const TextStyle(color: AppTheme.statusError, fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
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
      case "Rejected":
        return AppTheme.statusError;
      case "Applied":
        return AppTheme.statusWarning;
      default:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
