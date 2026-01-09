import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme/app_theme.dart';
import '../../dashboard/data/providers/dashboard_provider.dart';
import '../data/models/applied_leave_model.dart';
import '../data/providers/approvals_provider.dart';
import 'widgets/approval_sheet.dart';
import 'widgets/rejection_sheet.dart';
import 'package:intl/intl.dart';


class AppliedLeavesTab extends ConsumerStatefulWidget {
  const AppliedLeavesTab({super.key});

  @override
  ConsumerState<AppliedLeavesTab> createState() =>
      _LeaveAppliedTabState();
}

class _LeaveAppliedTabState extends ConsumerState<AppliedLeavesTab> {
  int _page = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    ref
        .read(leaveApprovalProvider.notifier)
        .loadAppliedLeaves(page: _page, limit: _limit);
  }

  // APPROVE (Partial/Itemized)
  void _showPartialApprovalSheet(AppliedLeaveItem item) {
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
          
          // Transform map to API structure: [{ "date": "...", "action": "APPROVE/REJECT" }]
          final apiDecisions = decisions.entries.map((e) => {
            "date": DateFormat('yyyy-MM-dd').format(e.key),
            "action": e.value ? "APPROVE" : "REJECT"
          }).toList();
          
          try {
            final res = await ref.read(leaveApprovalRepositoryProvider).approveLeave(
              leaveRoasterId: item.leaveRoasterId,
              decisions: apiDecisions,
              reason: reason,
            );
            _handleSuccess(res.message);
          } catch (e) {
            _handleError(e);
          }
        },
      ),
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
    ref.read(dashboardProvider.notifier).loadDashboard();
  }

  void _handleError(dynamic e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_extractErrorMessage(e)),
        backgroundColor: AppTheme.statusError,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // REJECT (Bottom Sheet)
  void _showRejectSheet(AppliedLeaveItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RejectionSheet(
        employeeName: item.employeeName,
        onSubmitted: (reason) async {
          Navigator.pop(context);

          try {
            final res = await ref
                .read(leaveApprovalRepositoryProvider)
                .rejectLeave(
              leaveRoasterId: item.leaveRoasterId,
              reason: reason,
            );

            _handleSuccess(res.message);
          } catch (e) {
            _handleError(e);
          }
        },
      ),
    );
  }

  String _extractErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('message:')) {
      final regex = RegExp(r'message:\s*([^,}]+)');
      final match = regex.firstMatch(errorStr);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    if (errorStr.startsWith('Exception: ')) {
      return errorStr.replaceFirst('Exception: ', '');
    }

    return errorStr;
  }

  Future<void> _refresh() async {
    _page = 1;
    await ref
        .read(leaveApprovalProvider.notifier)
        .loadAppliedLeaves(page: _page, limit: _limit);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveApprovalProvider);

    return state.when(
      loading: () =>
      const Center(child: CircularProgressIndicator()),
      error: (e, _) => RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(child: Text(_extractErrorMessage(e))),
          ),
        ),
      ),
      data: (data) {
        if (data == null || data.records.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height:
                MediaQuery.of(context).size.height * 0.8,
                child:
                const Center(child: Text("No applied leaves")),
              ),
            ),
          );
        }

        final items = data.records;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = items[i];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.employeeName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 4),

                    if (item.store != null)
                      Text(
                        "STORE: ${item.store}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),

                    if (item.empCode != null)
                      Text(
                        "EmpCode: ${item.empCode}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),

                    const SizedBox(height: 6),
                    Text(
                      "${item.fromDate} → ${item.toDate}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text("Type: ${item.leaveType}"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _showRejectSheet(item),
                            child: const Text("Reject"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                _showPartialApprovalSheet(item),
                            child: const Text("Approve"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
