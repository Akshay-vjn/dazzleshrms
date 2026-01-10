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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Approvals"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Applied Leaves"),
            Tab(text: "Modified Leaves"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AppliedLeavesTab(),
          ChangedLeavesTab(),
        ],
      ),
    );
  }
}
