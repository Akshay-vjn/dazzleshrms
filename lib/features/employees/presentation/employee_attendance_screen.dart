import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme/app_theme.dart';
import '../data/provider/employee_attendance_provider.dart';
import '../data/models/employee_attendance_model.dart';
import '../../attendance/presentation/widgets/shimmer_loading.dart';

class EmployeeAttendanceScreen extends ConsumerStatefulWidget {
  final int employeeId;
  final String employeeName;

  const EmployeeAttendanceScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  ConsumerState<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends ConsumerState<EmployeeAttendanceScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 10;
  bool _isLoadingMore = false;
  final List<EmployeeAttendance> _items = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    _items.clear();
    _currentPage = 1;
    ref.read(employeeAttendanceProvider(widget.employeeId).notifier).loadAttendance(
          page: _currentPage,
          limit: _limit,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 120 &&
        !_isLoadingMore) {
      final state = ref.read(employeeAttendanceProvider(widget.employeeId));
      state.whenOrNull(
        data: (data) {
          if (data == null) return;
          if (_currentPage < data.data.totalPages) {
            _loadNextPage();
          }
        },
      );
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await ref
        .read(employeeAttendanceProvider(widget.employeeId).notifier)
        .loadAttendance(page: _currentPage, limit: _limit);
    if (mounted) setState(() => _isLoadingMore = false);
  }

  Future<void> _onRefresh() async {
    _loadData();
  }

  Color _statusColor(String status) {
    status = status.toLowerCase();
    if (status.contains("present")) return AppTheme.statusSuccess;
    if (status.contains("absent")) return AppTheme.statusError;
    if (status.contains("half day")) return AppTheme.statusWarning;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(employeeAttendanceProvider(widget.employeeId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar
        (title: Text("Attendance"),
        centerTitle: true,),
      body: attendanceState.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 8,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (_, __) => const AttendanceShimmerItem(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString(), style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _onRefresh, child: const Text("Retry")),
            ],
          ),
        ),
        data: (attendanceData) {
          if (attendanceData == null) return const Center(child: Text("No records found"));

          for (final item in attendanceData.data.data) {
            if (!_items.any((e) => e.date == item.date)) {
              _items.add(item);
            }
          }

          if (_items.isEmpty) return const Center(child: Text("No records found"));

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    return const AttendanceShimmerItem();
                  }

                  final item = _items[index];
                  final statusColor = _statusColor(item.attendanceDescription);

                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Icon(
                        Icons.calendar_today_outlined,
                        color: statusColor,
                      ),
                      title: Text(
                        item.date,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        item.attendanceDescription,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
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
