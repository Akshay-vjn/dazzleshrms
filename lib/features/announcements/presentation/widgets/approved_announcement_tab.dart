import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/approved_announcement_provider.dart';
import 'package:url_launcher/url_launcher.dart';


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
                    _infoText(context, "Designation", item.designationName),
                    _infoText(context, "Employee", item.employeeName),
                    _infoText(context, "Created By", item.createdByName),
                    _infoText(context, "Approved By", item.approvedByName),
                    _infoText(context, "Rejected By", item.rejectedByName),
                    _infoText(context, "Created At", item.createdAt),

                    if (item.attachment != null &&
                        item.attachment!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final url = Uri.parse(item.attachment!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.red.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.picture_as_pdf,
                                  size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "View Attachment PDF",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

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
