import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      ref.read(allNotificationsProvider.notifier).loadNotifications(isRefresh: true);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (data) {
          if (data == null || data.records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "No notifications found",
                    style: TextStyle(color: Colors.grey),
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
