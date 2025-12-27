// features/leave_approval/presentation/approval_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/applied_leave_model.dart';
import '../../../core/app_theme/app_theme.dart';
import '../data/providers/approvals_provider.dart';

class ApprovalScreen extends ConsumerStatefulWidget {
  const ApprovalScreen({super.key});

  @override
  ConsumerState<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends ConsumerState<ApprovalScreen> {
  int _page = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    ref.read(leaveApprovalProvider.notifier)
        .loadAppliedLeaves(page: _page, limit: _limit);
  }

  void _showApproveDialog(int leaveId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Approve Leave"),
        content: const Text("Are you sure you want to approve this leave?"),
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
                  ),
                );

                _refresh();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_extractErrorMessage(e)),
                    backgroundColor: AppTheme.statusError,
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
              // Validate reason is not empty
              if (ctrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please provide a rejection reason"),
                    backgroundColor: AppTheme.statusError,
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
                  ),
                );

                _refresh();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_extractErrorMessage(e)),
                    backgroundColor: AppTheme.statusError,
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

  // Helper method to extract clean error messages
  String _extractErrorMessage(dynamic error) {
    final errorStr = error.toString();

    // If it's a formatted exception with a message field
    if (errorStr.contains('message:')) {
      final regex = RegExp(r'message:\s*([^,}]+)');
      final match = regex.firstMatch(errorStr);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    // If it's an Exception: prefix
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.replaceFirst('Exception: ', '');
    }

    // Return the full error if no pattern matched
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

    return Scaffold(
      appBar: AppBar(title: const Text("Leave Approvals")),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: const Center(child: Text("No applied leaves")),
                ),
              ),
            );
          }

          // Use data.records directly instead of accumulating in _items
          final items = data.records;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = items[i];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.employeeName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${item.fromDate} → ${item.toDate}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text("Type: ${item.leaveType}"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _showRejectDialog(item.leaveRoasterId),
                              child: const Text("Reject"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () =>
                                  _showApproveDialog(item.leaveRoasterId),
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
      ),
    );
  }
}