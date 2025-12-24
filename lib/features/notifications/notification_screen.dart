import 'package:dazzleshrms/features/notifications/widgets/notificationtile.dart';
import 'package:flutter/material.dart';


class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= TODAY =================
          Text(
            "Today",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),



          const NotificationTile(
            icon: Icons.event_available_outlined,
            title: "Leave Approved",
            message: "Your casual leave has been approved",
            time: "2h ago",
            isUnread: true,
          ),

          const SizedBox(height: 24),

          // ================= EARLIER =================
          Text(
            "Earlier",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),


          const NotificationTile(
            icon: Icons.info_outline,
            title: "HR Announcement",
            message: "Company meeting on Friday at 4 PM",
            time: "12 Sep",
            isUnread: false,
          ),
        ],
      ),
    );
  }
}
