import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/approved_announcement_provider.dart';


class ApprovedAnnouncementsTab extends ConsumerStatefulWidget {
  const ApprovedAnnouncementsTab({super.key});

  @override
  ConsumerState<ApprovedAnnouncementsTab> createState() =>
      _ApprovedAnnouncementsTabState();
}

class _ApprovedAnnouncementsTabState
    extends ConsumerState<ApprovedAnnouncementsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(approvedAnnouncementsProvider.notifier).loadApproved();
    });
  }

  Widget _infoText(BuildContext context, String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        "$label: $value",
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(approvedAnnouncementsProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (data) {
        if (data == null || data.records.isEmpty) {
          return const Center(child: Text("No approved announcements"));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = data.records[index];

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      item.announcement,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 8),

                    _infoText(context, "Status", item.status),
                    _infoText(context, "Store", item.storeName),
                    _infoText(context, "Employee", item.employeeName),
                    _infoText(context, "Created By", item.createdByName),
                    _infoText(context, "Approved By", item.approvedByName),
                    _infoText(context, "Rejected By", item.rejectedByName),
                    _infoText(context, "Created At", item.createdAt),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        item.status.toLowerCase() == "approved"
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: item.status.toLowerCase() == "approved"
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
