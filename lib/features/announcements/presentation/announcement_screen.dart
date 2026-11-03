import 'package:dazzleshrms/core/app_theme/app_page_bar.dart';
import 'package:dazzleshrms/core/app_theme/app_scaffold.dart';
import 'package:dazzleshrms/features/announcements/presentation/create_announcement_screen.dart';
import 'package:dazzleshrms/features/announcements/presentation/widgets/approved_announcement_tab.dart';
import 'package:dazzleshrms/features/announcements/presentation/widgets/pending_announcement_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/permissions/permission.dart';
import '../../../core/permissions/permission_provider.dart';

class AnnouncementScreen extends ConsumerStatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  ConsumerState<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends ConsumerState<AnnouncementScreen>
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
  PreferredSizeWidget _buildTabBar(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            indicator: BoxDecoration(
              color: primary.withOpacity(isDark ? 0.28 : 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withOpacity(0.7), width: 1),
            ),
            labelColor: isDark ? Colors.white : primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: "Approved"),
              Tab(text: "Pending"),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final permissions = ref.watch(permissionProvider);
    final canCreateAnnouncement = permissions.contains(
      Permissions.viewCreateAnnouncement,
    );

    return AppScaffold(
      appBar: AppPageBar(
        title: 'Announcements',
        bottom: _buildTabBar(theme),
      ),

      floatingActionButton: canCreateAnnouncement
          ? Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom,
        ),
        child: FloatingActionButton(
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
      )
          : null,

      body: TabBarView(
        controller: _tabController,
        children: const [ApprovedAnnouncementsTab(), PendingAnnouncementsTab()],
      ),
    );
  }
}