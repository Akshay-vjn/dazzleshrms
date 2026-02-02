import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dazzleshrms/features/announcements/data/providers/announcement_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_theme/app_theme.dart';

class EmployeeAnnouncementScreen extends ConsumerStatefulWidget {
  const EmployeeAnnouncementScreen({super.key});

  @override
  ConsumerState<EmployeeAnnouncementScreen> createState() => _EmployeeAnnouncementScreenState();
}

class _EmployeeAnnouncementScreenState extends ConsumerState<EmployeeAnnouncementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.invalidate(employeeAnnouncementsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final announcementsState = ref.watch(employeeAnnouncementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(employeeAnnouncementsProvider.future),
        child: announcementsState.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppTheme.statusError.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Oops! Something went wrong",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () =>
                                ref.refresh(employeeAnnouncementsProvider.future),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Try Again"),
                  ),
                ],
              ),
            ),
          ),
          data: (data) {
            if (data.records.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: const Center(child: Text("No announcements found")),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.records.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final announcement = data.records[index];
                return Card(
                  elevation: 0,
                  color: theme.brightness == Brightness.dark
                      ? AppTheme.surfaceDark
                      : AppTheme.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                announcement.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              announcement.createdAt,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          announcement.announcement,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "Posted by ${announcement.createdBy}",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            if (announcement.attachment != null &&
                                announcement.attachment!.isNotEmpty)
                              InkWell(
                                onTap: () async {
                                  final url = Uri.parse(announcement.attachment!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
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
                                          size: 14, color: Colors.red),
                                      SizedBox(width: 4),
                                      Text(
                                        "PDF",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
