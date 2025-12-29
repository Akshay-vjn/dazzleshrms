import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme/app_theme.dart';
import '../data/providers/approvals_provider.dart';

class AppliedLeavesTab extends ConsumerStatefulWidget {
  const AppliedLeavesTab({super.key});

  @override
  ConsumerState<AppliedLeavesTab> createState() => _AppliedLeavesTabState();
}

class _AppliedLeavesTabState extends ConsumerState<AppliedLeavesTab> {
  int _page = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    ref.read(leaveApprovalProvider.notifier)
        .loadAppliedLeaves(page: _page, limit: _limit);
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (data) {
        if (data == null || data.records.isEmpty) {
          return const Center(child: Text("No applied leaves"));
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = data.records[i];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.employeeName,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text("${item.fromDate} → ${item.toDate}"),
                    const SizedBox(height: 6),
                    Text("Type: ${item.leaveType}"),
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
