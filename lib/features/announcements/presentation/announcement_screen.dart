import 'package:dazzleshrms/features/announcements/presentation/create_announcement_screen.dart';
import 'package:dazzleshrms/features/announcements/presentation/widgets/approved_announcement_tab.dart';
import 'package:dazzleshrms/features/announcements/presentation/widgets/pending_announcement_tab.dart';
import 'package:flutter/material.dart';


class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: "Approved"),
            Tab(text: "Pending"),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAnnouncementScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: TabBarView(
        controller: _tabController,
        children: const [
          ApprovedAnnouncementsTab(),
          PendingAnnouncementsTab(),
        ],
      ),
    );
  }
}
