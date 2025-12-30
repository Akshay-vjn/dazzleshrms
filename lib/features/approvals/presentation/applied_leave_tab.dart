import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme/app_theme.dart';
import '../data/providers/approvals_provider.dart';

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

  // ================= APPROVE =================
  void _showApproveDialog(int leaveId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Approve Leave"),
        content:
        const Text("Are you sure you want to approve this leave?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final res = await ref
                    .read(leaveApprovalRepositoryProvider)
                    .approveLeave(leaveId);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.message),
                    backgroundColor: AppTheme.statusSuccess,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );

                _refresh();
              } catch (e) {
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
            },
            child: const Text("Approve"),
          ),
        ],
      ),
    );
  }

  // ================= REJECT =================
  void _showRejectDialog(int leaveId) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Leave"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: "Enter reject reason",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                    Text("Please provide a rejection reason"),
                    backgroundColor: AppTheme.statusError,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16),
                  ),
                );
                return;
              }

              Navigator.pop(context);

              try {
                final res = await ref
                    .read(leaveApprovalRepositoryProvider)
                    .rejectLeave(
                  leaveRoasterId: leaveId,
                  reason: ctrl.text.trim(),
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.message),
                    backgroundColor: AppTheme.statusError,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );

                _refresh();
              } catch (e) {
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
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  // ================= ERROR PARSER =================
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

  // ================= REFRESH =================
  Future<void> _refresh() async {
    _page = 1;
    await ref
        .read(leaveApprovalProvider.notifier)
        .loadAppliedLeaves(page: _page, limit: _limit);
  }

  // ================= BUILD =================
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
                                _showRejectDialog(
                                    item.leaveRoasterId),
                            child: const Text("Reject"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                _showApproveDialog(
                                    item.leaveRoasterId),
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
