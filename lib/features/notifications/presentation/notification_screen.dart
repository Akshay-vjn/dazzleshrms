import 'package:dazzleshrms/core/app_theme/app_page_bar.dart';
import 'package:dazzleshrms/core/app_theme/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme/app_visuals.dart';
import '../data/provider/notification_provider.dart';
import './widgets/notificationtile.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(allNotificationsProvider.notifier)
          .loadNotifications(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(allNotificationsProvider.notifier).loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allNotificationsProvider);
    final notifier = ref.read(allNotificationsProvider.notifier);
    final colors = AppVisuals.of(context);
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: const AppPageBar(title: 'Notifications'),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: colors.red),
                const SizedBox(height: 16),
                Text(
                  "Oops! Something went wrong",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => notifier.loadNotifications(isRefresh: true),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Try Again"),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          if (data == null || data.records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.accentSurface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 40,
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No notifications found",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await notifier.loadNotifications(isRefresh: true);
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: data.records.length + (notifier.hasNextPage ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == data.records.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final item = data.records[index];
                return NotificationTile(
                  icon: _getIconForType(item.type),
                  title: item.title,
                  message: item.message,
                  time: item.createdAt,
                  isUnread: !item.isRead,
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'LEAVE':
        return Icons.calendar_today_outlined;
      case 'ANNOUNCEMENT':
        return Icons.campaign_outlined;
      case 'ATTENDANCE':
        return Icons.access_time;
      default:
        return Icons.notifications_outlined;
    }
  }
}
