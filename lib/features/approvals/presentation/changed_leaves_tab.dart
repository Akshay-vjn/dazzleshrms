import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/changed_leave_provider.dart';
import '../data/providers/changedtab_actions_provider.dart';

class ChangedLeavesTab extends ConsumerStatefulWidget {
  const ChangedLeavesTab({super.key});

  @override
  ConsumerState<ChangedLeavesTab> createState() =>
      _ChangedLeavesTabState();
}

class _ChangedLeavesTabState
    extends ConsumerState<ChangedLeavesTab> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pendingLeaveProvider.notifier).loadPendingLeaves();
    });
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _confirmAction({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pendingLeaveProvider);

    return state.when(
      loading: () =>
      const Center(child: CircularProgressIndicator()),

      error: (e, _) =>
          Center(child: Text(e.toString())),

      data: (data) {
        if (data == null || data.records.isEmpty) {
          return const Center(child: Text("No changed leaves"));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(pendingLeaveProvider.notifier)
                .loadPendingLeaves();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.records.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = data.records[i];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .dividerColor
                        .withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    Text(
                      item.date,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      item.employeeName,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Store: ${item.storeName}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),

                    const SizedBox(height: 10),


                    Row(
                      children: [
                        Text(
                          item.changesFrom,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          item.changesTo,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),


                    Text(
                      "Days Taken: ${item.daysTaken}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 8),



                    const SizedBox(height: 14),


                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _confirmAction(
                                context: context,
                                title: "Reject Change",
                                message:
                                "Reject this leave modification request?",
                                onConfirm: () async {
                                  try {
                                    final res = await ref
                                        .read(
                                      changedTabRepositoryProvider,
                                    )
                                        .rejectChange(item.logId);

                                    if (!mounted) return;

                                    _showSnack(
                                      context,
                                      res.message,
                                      Colors.red,
                                    );

                                    ref
                                        .read(
                                      pendingLeaveProvider.notifier,
                                    )
                                        .loadPendingLeaves();
                                  } catch (e) {
                                    _showSnack(
                                      context,
                                      e
                                          .toString()
                                          .replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                      Colors.red,
                                    );
                                  }
                                },
                              );
                            },
                            child: const Text("Reject"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              _confirmAction(
                                context: context,
                                title: "Approve Change",
                                message:
                                "Approve this leave modification request?",
                                onConfirm: () async {
                                  try {
                                    final res = await ref
                                        .read(
                                      changedTabRepositoryProvider,
                                    )
                                        .approveChange(item.logId);

                                    if (!mounted) return;

                                    _showSnack(
                                      context,
                                      res.message,
                                      Colors.green,
                                    );

                                    ref
                                        .read(
                                      pendingLeaveProvider.notifier,
                                    )
                                        .loadPendingLeaves();
                                  } catch (e) {
                                    _showSnack(
                                      context,
                                      e
                                          .toString()
                                          .replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                      Colors.red,
                                    );
                                  }
                                },
                              );
                            },
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
