import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/pending_announcement_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'announcement_tile.dart';

class PendingAnnouncementsTab extends ConsumerStatefulWidget {
  const PendingAnnouncementsTab({super.key});

  @override
  ConsumerState<PendingAnnouncementsTab> createState() =>
      _PendingAnnouncementsTabState();
}

class _PendingAnnouncementsTabState
    extends ConsumerState<PendingAnnouncementsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pendingAnnouncementsProvider.notifier).loadPending();
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
    final state = ref.watch(pendingAnnouncementsProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (data) {
        if (data == null || data.records.isEmpty) {
          return const Center(child: Text("No pending announcements"));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final item = data.records[index];

            return AnnouncementTile(
              icon: Icons.campaign_rounded,
              title: item.title,
              message: item.announcement,
              date: item.createdAt,

              extra: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoText(context, "Status", item.status),
                  _infoText(context, "Store", item.storeName),
                  _infoText(context, "Designation", item.designationName),
                  _infoText(context, "Employee", item.employeeName),
                  _infoText(context, "Created By", item.createdByName),
                  if (item.attachment != null &&
                      item.attachment!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: InkWell(
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
                    ),
                ],
              ),

              footer: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(pendingAnnouncementsProvider.notifier)
                            .reject(item.announcementId);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Reject"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(pendingAnnouncementsProvider.notifier)
                            .approve(item.announcementId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Approve"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
