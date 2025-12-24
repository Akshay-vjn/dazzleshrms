import 'package:dazzleshrms/features/announcements/widgets/announcement_tile.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= THIS WEEK =================
          Text(
            "This Week",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          AnnouncementTile(
            icon: Icons.celebration_outlined,
            title: "Team Building Event",
            message: "Join us for a team building event this Friday at 3 PM. We'll have fun activities, games, and refreshments!",
            date: "Today",
            iconColor: AppTheme.SecondaryColor,
          ),

          AnnouncementTile(
            icon: Icons.update_outlined,
            title: "System Maintenance",
            message: "HRMS system will undergo scheduled maintenance on Saturday from 2 AM to 6 AM. Please plan accordingly.",
            date: "Yesterday",
            iconColor: AppTheme.PrimaryColor,
          ),

          const SizedBox(height: 24),

          // ================= EARLIER =================
          Text(
            "Earlier",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          AnnouncementTile(
            icon: Icons.policy_outlined,
            title: "Updated Leave Policy",
            message: "New leave policy has been implemented. Please review the updated guidelines in the employee handbook.",
            date: "Dec 15",
            iconColor: AppTheme.PrimaryColor,
          ),

          AnnouncementTile(
            icon: Icons.card_giftcard_outlined,
            title: "Holiday Bonus Announcement",
            message: "We're pleased to announce year-end bonuses will be credited by December 20th. Happy Holidays!",
            date: "Dec 10",
            iconColor: AppTheme.SecondaryColor,
          ),



        ],
      ),
    );
  }
}
