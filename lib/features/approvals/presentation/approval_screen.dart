import 'package:dazzleshrms/core/app_theme/app_page_bar.dart';
import 'package:dazzleshrms/core/app_theme/app_scaffold.dart';
import 'package:flutter/material.dart';

import 'applied_leave_tab.dart';
import 'modified_leaves_tab.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen>
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
              color: primary.withValues(alpha: isDark ? 0.28 : 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primary.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            labelColor: isDark ? Colors.white : primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: "Applied Leaves"),
              Tab(text: "Modified Leaves"),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      appBar: AppPageBar(title: 'Leave Approvals', bottom: _buildTabBar(theme)),
      body: TabBarView(
        controller: _tabController,
        children: const [AppliedLeavesTab(), ChangedLeavesTab()],
      ),
    );
  }
}
