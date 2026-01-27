import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme/app_theme.dart';
import '../data/provider/employee_leave_provider.dart';

class EmployeeUpcomingLeavesScreen extends ConsumerStatefulWidget {
  final int employeeId;
  final String employeeName;

  const EmployeeUpcomingLeavesScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  ConsumerState<EmployeeUpcomingLeavesScreen> createState() => _EmployeeUpcomingLeavesScreenState();
}

class _EmployeeUpcomingLeavesScreenState extends ConsumerState<EmployeeUpcomingLeavesScreen> {
  final int _limit = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    await ref.read(employeeUpcomingLeavesProvider(widget.employeeId).notifier).loadUpcomingLeaves(
          page: _currentPage,
          limit: _limit,
        );
  }

  @override
  Widget build(BuildContext context) {
    final upcomingState = ref.watch(employeeUpcomingLeavesProvider(widget.employeeId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcoming Leaves"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: upcomingState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(child: Text(error.toString())),
            ),
          ),
          data: (data) {
            if (data == null || data.data.records.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const Center(child: Text("No upcoming leaves")),
                ),
              );
            }

            final items = data.data.records;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.PrimaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event_available, color: AppTheme.PrimaryColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.date,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Type: ${item.type}",
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.statusSuccess.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status,
                          style: const TextStyle(
                            color: AppTheme.statusSuccess,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
