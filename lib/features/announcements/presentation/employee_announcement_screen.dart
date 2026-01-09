import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dazzleshrms/features/announcements/data/providers/announcement_provider.dart';

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
    // Refresh announcements when the screen is first opened
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
          error: (e, _) => ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(child: Text("Error: $e")),
              ),
            ],
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
                          children: [
                            const Icon(Icons.person_outline, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "Posted by ${announcement.createdBy}",
                              style: theme.textTheme.bodySmall,
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
