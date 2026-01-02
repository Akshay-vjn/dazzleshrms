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

      ref.read(attendanceProvider.notifier).loadAttendance(
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

    await ref.read(attendanceProvider.notifier).loadAttendance(
      page: _currentPage,
      limit: _limit,
    );

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

    await ref.read(attendanceProvider.notifier).loadAttendance(
      page: _currentPage,
      limit: _limit,
      forceRefresh: true,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Present":
        return AppTheme.statusSuccess;
      case "Absent":
        return AppTheme.statusError;
      case "Half day-in":
      case "Half day-out":
        return AppTheme.statusWarning;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),
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
              itemCount: _items.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return const AttendanceShimmerItem();
                }

                final item = _items[index];
                final statusColor = _statusColor(item.status);

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .dividerColor
                          .withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .shadowColor
                            .withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 72,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.date,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  statusColor.withOpacity(0.15),
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item.status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
}
