import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/app_theme/app_theme.dart';
import '../data/models/employee_dashboard_attendance_response.dart';
import '../data/providers/break_report_provider.dart';

class EmployeeDashboardAttendanceTab extends ConsumerStatefulWidget {
  final int employeeId;
  final String? fromDate;
  final String? toDate;

  const EmployeeDashboardAttendanceTab({
    super.key,
    required this.employeeId,
    this.fromDate,
    this.toDate,
  });

  @override
  ConsumerState<EmployeeDashboardAttendanceTab> createState() =>
      _EmployeeDashboardAttendanceTabState();
}

class _EmployeeDashboardAttendanceTabState
    extends ConsumerState<EmployeeDashboardAttendanceTab> {
  final ScrollController _scrollController = ScrollController();
  final _displayFormat = DateFormat('dd MMM yyyy');
  int _currentPage = 1;
  bool _isLoadingMore = false;

  int get _limit {
    try {
      final size = MediaQuery.of(context).size;
      return (size.shortestSide >= 600 || size.height >= 900) ? 25 : 15;
    } catch (_) {
      return 20;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
  }

  @override
  void didUpdateWidget(covariant EmployeeDashboardAttendanceTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fromDate != widget.fromDate ||
        oldWidget.toDate != widget.toDate) {
      _load(reset: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false, bool append = false}) async {
    if (reset) {
      _currentPage = 1;
      _isLoadingMore = false;
    }
    await ref
        .read(employeeDashboardAttendanceProvider(widget.employeeId).notifier)
        .fetchAttendance(
          page: _currentPage,
          limit: _limit,
          fromDate: widget.fromDate,
          toDate: widget.toDate,
          append: append,
        );
    if (mounted) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _checkIfNeedMoreData());
    }
  }

  void _checkIfNeedMoreData() {
    if (!mounted || !_scrollController.hasClients || _isLoadingMore) return;
    if (_scrollController.position.maxScrollExtent <= 100) {
      final data =
          ref.read(employeeDashboardAttendanceProvider(widget.employeeId)).valueOrNull;
      if (data == null) return;
      final hasMorePages = data.totalPages > 0
          ? _currentPage < data.totalPages
          : (data.totalItems > 0
              ? data.data.length < data.totalItems
              : data.data.length >= _currentPage * _limit);
      if (hasMorePages) {
        _loadNextPage();
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll < maxScroll - 150) return;

    final data =
        ref.read(employeeDashboardAttendanceProvider(widget.employeeId)).valueOrNull;
    if (data == null) return;
    final hasMorePages = data.totalPages > 0
        ? _currentPage < data.totalPages
        : (data.totalItems > 0
            ? data.data.length < data.totalItems
            : data.data.length >= _currentPage * _limit);
    if (!hasMorePages) return;
    _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;
    await ref
        .read(employeeDashboardAttendanceProvider(widget.employeeId).notifier)
        .fetchAttendance(
          page: nextPage,
          limit: _limit,
          fromDate: widget.fromDate,
          toDate: widget.toDate,
          append: true,
        );
    if (mounted) {
      setState(() {
        _currentPage = nextPage;
        _isLoadingMore = false;
      });
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _checkIfNeedMoreData());
    }
  }

  Color _statusColor(String status) {
    if (status.isEmpty) return AppTheme.textMutedLight;
    final value = status.toLowerCase();
    if (value.contains('absent')) return AppTheme.statusError;
    if (value.contains('half')) return AppTheme.statusWarning;
    if (value.contains('leave')) return AppTheme.statusInfo;
    if (value.contains('present')) return AppTheme.statusSuccess;
    return AppTheme.textMutedLight;
  }

  String _prettyDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return _displayFormat.format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state =
        ref.watch(employeeDashboardAttendanceProvider(widget.employeeId));

    return state.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: AppTheme.PrimaryColor),
      ),
      error: (err, _) => _emptyState(
        isDark,
        icon: Icons.error_outline_rounded,
        title: 'Failed to load attendance',
        message: err.toString(),
        retry: () => _load(reset: true),
      ),
      data: (data) {
        if (data == null || data.data.isEmpty) {
          return _emptyState(
            isDark,
            icon: Icons.event_busy_rounded,
            title: 'No attendance records',
            message: 'No attendance found for this period.',
          );
        }
        final extra = _isLoadingMore ? 1 : 0;
        return RefreshIndicator(
          color: AppTheme.PrimaryColor,
          onRefresh: () => _load(reset: true),
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: data.data.length + extra,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index >= data.data.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return _attendanceCard(isDark, data.data[index]);
            },
          ),
        );
      },
    );
  }

  Widget _attendanceCard(bool isDark, EmployeeDashboardAttendanceItem item) {
    // "No Update" = empty/null description, or attendanceTypeId == 0,
    // or description explicitly says "no update" / "n/a", or no check-in at all
    final descLower = item.attendanceDescription.toLowerCase().trim();
    final isNoUpdate = item.attendanceDescription.trim().isEmpty ||
        item.attendanceTypeId == 0 ||
        descLower == 'no update' ||
        descLower == 'n/a' ||
        descLower == 'na' ||
        (item.checkinTime == null && item.checkoutTime == null &&
            !descLower.contains('absent') &&
            !descLower.contains('leave') &&
            !descLower.contains('holiday') &&
            !descLower.contains('half'));
    final statusLabel = isNoUpdate ? 'No Update' : item.attendanceDescription;
    final statusColor = _statusColor(isNoUpdate ? '' : item.attendanceDescription);
    final isAbsent = descLower.contains('absent');
    final hideDetails = isAbsent || isNoUpdate;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _prettyDate(item.date),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (!hideDetails) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _timeTile(
                    isDark,
                    'Check-in',
                    item.checkinTime ?? '—',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _timeTile(
                    isDark,
                    'Check-out',
                    item.checkoutTime ?? '—',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _timeTile(
                    isDark,
                    'Hours',
                    item.workingHours.isEmpty ? '—' : item.workingHours,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeTile(bool isDark, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgDark : AppTheme.bgLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(
    bool isDark, {
    required IconData icon,
    required String title,
    required String message,
    VoidCallback? retry,
  }) {
    return RefreshIndicator(
      color: AppTheme.PrimaryColor,
      onRefresh: () => _load(reset: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: AppTheme.accent(isDark)),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color:
                          isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                  if (retry != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: retry,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.PrimaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
