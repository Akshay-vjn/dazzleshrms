import 'package:dazzleshrms/core/app_theme/app_page_bar.dart';
import 'package:dazzleshrms/core/app_theme/app_scaffold.dart';
import 'package:dazzleshrms/core/app_theme/glass_surface.dart';
import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:dazzleshrms/features/attendance/presentation/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_theme/app_theme.dart';
import '../data/models/attendance_model.dart';
import '../data/providers/attendance_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  final int _limit = 10;
  bool _isLoadingMore = false;
  bool _isSummaryExpanded = false;

  final List<AttendanceItem> _items = [];

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(attendanceProvider.notifier).reset();
      _items.clear();
      _currentPage = 1;
      _isLoadingMore = false;

      ref
          .read(attendanceProvider.notifier)
          .loadAttendance(
            page: _currentPage,
            limit: _limit,
            forceRefresh: true,
          );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 120 &&
        !_isLoadingMore) {
      final state = ref.read(attendanceProvider);

      state.whenOrNull(
        data: (data) {
          if (data == null) return;
          if (_currentPage < data.totalPages) {
            _loadNextPage();
          }
        },
      );
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    _currentPage++;

    await ref
        .read(attendanceProvider.notifier)
        .loadAttendance(page: _currentPage, limit: _limit);

    if (!mounted) return;

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    _isLoadingMore = false;
    _items.clear();
    await Future.delayed(const Duration(seconds: 1));

    await ref
        .read(attendanceProvider.notifier)
        .loadAttendance(page: _currentPage, limit: _limit, forceRefresh: true);
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Present":
        return AppVisuals.of(context).green;
      case "Absent":
        return AppVisuals.of(context).red;
      case "Half day-in":
      case "Half day-out":
        return AppTheme.statusWarning;
      default:
        return AppVisuals.of(context).muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);

    return AppScaffold(
      appBar: const AppPageBar(title: 'Attendance'),
      body: attendanceState.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 8,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => const AttendanceShimmerItem(),
        ),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (attendanceData) {
          if (attendanceData == null) {
            return const Center(child: Text("No data found"));
          }

          for (final item in attendanceData.records) {
            if (!_items.any((e) => e.date == item.date)) {
              _items.add(item);
            }
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _items.length + (_isLoadingMore ? 1 : 0) + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSummaryCard(context, attendanceData);
                }

                final listIndex = index - 1;
                if (listIndex == _items.length) {
                  return const AttendanceShimmerItem();
                }

                final item = _items[listIndex];
                final statusColor = _statusColor(item.status);

                final theme = Theme.of(context);

                return GlassSurface(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.fingerprint,
                        color: statusColor,
                      ),
                    ),
                    title: Text(
                      item.date,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Text(
                        item.status,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSummaryCard(
    BuildContext context,
    AttendanceData attendanceData,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final summaryCounts = attendanceData.summary.counts;
    final sortedCounts = summaryCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return GlassSurface(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total ",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attendanceData.totalItems.toString(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppVisuals(isDark).accent,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _isSummaryExpanded = !_isSummaryExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          attendanceData.summary.month.isEmpty
                              ? "Month"
                              : attendanceData.summary.month,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isSummaryExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppVisuals(isDark).accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isSummaryExpanded) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              if (sortedCounts.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "No leave counts available",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: sortedCounts
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                entry.value.toString(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppVisuals(isDark).accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
