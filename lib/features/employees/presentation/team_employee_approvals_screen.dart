import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/features/approvals/presentation/widgets/approval_sheet.dart';
import 'package:dazzleshrms/features/approvals/presentation/widgets/rejection_sheet.dart';
import 'package:dazzleshrms/features/employees/data/models/employee_pending_leave_model.dart';
import 'package:dazzleshrms/features/employees/data/provider/employee_leave_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TeamEmployeeApprovalsScreen extends ConsumerStatefulWidget {
  const TeamEmployeeApprovalsScreen({super.key});

  @override
  ConsumerState<TeamEmployeeApprovalsScreen> createState() => _TeamEmployeeApprovalsScreenState();
}

class _TeamEmployeeApprovalsScreenState extends ConsumerState<TeamEmployeeApprovalsScreen> {
  final int _limit = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    await ref.read(teamEmployeePendingLeavesProvider.notifier).loadPendingLeaves(
          page: _currentPage,
          limit: _limit,
        );
  }

  void _handleSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.statusSuccess,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
    _refresh();
  }

  void _handleError(dynamic e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppTheme.statusError,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showPartialApprovalSheet(EmployeePendingLeaveItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ApprovalSheet(
        employeeName: item.employeeName,
        fromDate: item.fromDate,
        toDate: item.toDate,
        onSubmitted: (decisions, reason) async {
          Navigator.pop(context);

          final apiDecisions = decisions.entries
              .map((e) => {
                    "date": DateFormat('yyyy-MM-dd').format(e.key),
                    "action": e.value ? "APPROVE" : "REJECT",
                  })
              .toList();

          try {
            await ref.read(employeeLeaveApprovalProvider.notifier).approveLeave(
                  leaveRoasterId: item.leaveRoasterId,
                  decisions: apiDecisions,
                  rejectReason: reason,
                );
            _handleSuccess("Leave processed successfully");
          } catch (e) {
            _handleError(e);
          }
        },
      ),
    );
  }

  void _showRejectSheet(EmployeePendingLeaveItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RejectionSheet(
        employeeName: item.employeeName,
        onSubmitted: (reason) async {
          Navigator.pop(context);

          try {
            await ref.read(employeeLeaveApprovalProvider.notifier).rejectLeave(
                  leaveRoasterId: item.leaveRoasterId,
                  rejectReason: reason,
                );
            _handleSuccess("Leave rejected successfully");
          } catch (e) {
            _handleError(e);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingState = ref.watch(teamEmployeePendingLeavesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Approvals"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: pendingState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(child: Text(error.toString())),
            ),
          ),
          data: (data) {
            if (data == null || data.data.records.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const Center(child: Text("No pending approvals")),
                ),
              );
            }

            final items = data.data.records;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = items[index];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.employeeName,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.statusWarning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Pending",
                              style: TextStyle(color: AppTheme.statusWarning, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _infoRow(context, Icons.badge_outlined, "Code: ${item.empCode}"),
                      _infoRow(context, Icons.work_outline, item.designation),
                      _infoRow(context, Icons.storefront_outlined, item.store),
                      _infoRow(context, Icons.calendar_today_outlined, "${item.fromDate} → ${item.toDate}"),
                      _infoRow(context, Icons.category_outlined, "Type: ${item.leaveType}"),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showRejectSheet(item),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.statusError),
                                foregroundColor: AppTheme.statusError,
                              ),
                              child: const Text("Reject"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _showPartialApprovalSheet(item),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.statusSuccess,
                              ),
                              child: const Text("Approve"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Theme.of(context).hintColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
