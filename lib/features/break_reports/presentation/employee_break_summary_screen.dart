import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/app_theme/app_theme.dart';
import '../data/models/break_dashboard_employee_response.dart';
import '../data/models/employee_dashboard_summary_response.dart';
import '../data/providers/break_report_provider.dart';
import 'employee_dashboard_attendance_tab.dart';
import 'employee_dashboard_breaks_tab.dart';
import 'widgets/employee_avatar.dart';

class EmployeeBreakSummaryScreen extends ConsumerStatefulWidget {
  final BreakDashboardEmployeeItem employee;
  final DateTimeRange? initialDateRange;

  const EmployeeBreakSummaryScreen({
    super.key,
    required this.employee,
    this.initialDateRange,
  });

  @override
  ConsumerState<EmployeeBreakSummaryScreen> createState() =>
      _EmployeeBreakSummaryScreenState();
}

class _EmployeeBreakSummaryScreenState
    extends ConsumerState<EmployeeBreakSummaryScreen>
    with SingleTickerProviderStateMixin {
  DateTimeRange? _selectedRange;
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _displayFormat = DateFormat('dd MMM yyyy');
  late final TabController _tabController;

  String? get _fromDate => _selectedRange == null
      ? null
      : _dateFormat.format(_selectedRange!.start);

  String? get _toDate =>
      _selectedRange == null ? null : _dateFormat.format(_selectedRange!.end);

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialDateRange;
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSummary());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSummary() {
    ref.read(employeeDashboardSummaryProvider(widget.employee.employeeId).notifier).fetchSummary(
          fromDate: _fromDate,
          toDate: _toDate,
        );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: _selectedRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
      builder: (context, child) {
        final theme = Theme.of(context);
        final actionColor = theme.brightness == Brightness.light
            ? AppTheme.textPrimaryLight
            : AppTheme.PrimaryColor;
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppTheme.PrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: actionColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() => _selectedRange = picked);
    _loadSummary();
  }

  void _clearDateRange() {
    if (_selectedRange == null) return;
    setState(() => _selectedRange = null);
    _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppTheme.accent(isDark);
    final state =
        ref.watch(employeeDashboardSummaryProvider(widget.employee.employeeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Summary'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: accent,
          unselectedLabelColor:
              isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
          indicatorColor: accent,
          tabs: const [
            Tab(text: 'Summary'),
            Tab(text: 'Attendance'),
            Tab(text: 'Breaks'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedRange != null
                            ? accent.withValues(alpha: isDark ? 0.12 : 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedRange != null
                              ? accent.withValues(alpha: isDark ? 0.5 : 0.45)
                              : theme.dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.date_range_rounded,
                            size: 18,
                            color: accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedRange == null
                                  ? 'Select date range'
                                  : '${_displayFormat.format(_selectedRange!.start)} - ${_displayFormat.format(_selectedRange!.end)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedRange != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: _selectedRange != null
                                    ? accent
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (_selectedRange != null)
                            GestureDetector(
                              onTap: _clearDateRange,
                              child: Icon(
                                Icons.cancel_rounded,
                                size: 18,
                                color: accent,
                              ),
                            )
                          else
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                state.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.PrimaryColor,
                    ),
                  ),
                  error: (err, _) => _buildError(isDark, err.toString()),
                  data: (data) {
                    if (data == null) {
                      return const Center(child: Text('No summary found'));
                    }
                    return RefreshIndicator(
                      color: AppTheme.PrimaryColor,
                      onRefresh: () async => _loadSummary(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        children: [
                          _buildProfileCard(isDark, data),
                          const SizedBox(height: 12),
                          _buildPeriodCard(isDark, data.period),
                          const SizedBox(height: 12),
                          _buildShiftCard(isDark, data.shift),
                          const SizedBox(height: 12),
                          _buildAttendanceCard(isDark, data.attendance),
                          const SizedBox(height: 12),
                          _buildBreaksCard(isDark, data.breaks),
                        ],
                      ),
                    );
                  },
                ),
                EmployeeDashboardAttendanceTab(
                  employeeId: widget.employee.employeeId,
                  fromDate: _fromDate,
                  toDate: _toDate,
                ),
                EmployeeDashboardBreaksTab(
                  employeeId: widget.employee.employeeId,
                  fromDate: _fromDate,
                  toDate: _toDate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: AppTheme.statusError),
            const SizedBox(height: 12),
            Text(
              'Failed to load summary',
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSummary,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.PrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isDark, EmployeeDashboardSummaryData data) {
    final emp = data.employee;
    final name = emp.employeeName.isEmpty
        ? widget.employee.employeeName
        : emp.employeeName;
    final image = emp.profileImage.isNotEmpty
        ? emp.profileImage
        : widget.employee.profileImage;
    return _card(
      isDark: isDark,
      child: Row(
        children: [
          EmployeeAvatar(
            name: name,
            profileImage: image,
            enablePreview: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  emp.employeeCode.isEmpty
                      ? widget.employee.employeeCode
                      : emp.employeeCode,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.accent(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                // Text(
                //   'Designation: ${emp.employeeDesignation}  •  Store: ${emp.storeId}',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: isDark
                //         ? AppTheme.textMutedDark
                //         : AppTheme.textMutedLight,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(bool isDark, EmployeeDashboardPeriod period) {
    return _card(
      isDark: isDark,
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded,
              size: 18, color: AppTheme.accent(isDark)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Period',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.textMutedDark
                        : AppTheme.textMutedLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_prettyDate(period.fromDate)}  →  ${_prettyDate(period.toDate)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(bool isDark, EmployeeDashboardShift shift) {
    return _section(
      isDark: isDark,
      title: 'Shift',
      children: [
        Row(
          children: [
            Expanded(
              child: _statTile(
                isDark,
                'From',
                _prettyTime(shift.fromTime),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(isDark, 'To', _prettyTime(shift.toTime)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(isDark, 'Duration', shift.shiftDuration),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(
    bool isDark,
    EmployeeDashboardAttendance attendance,
  ) {
    final percent = attendance.attendancePercentage % 1 == 0
        ? attendance.attendancePercentage.toInt().toString()
        : attendance.attendancePercentage.toStringAsFixed(2);
    return _section(
      isDark: isDark,
      title: 'Attendance',
      children: [
        Row(
          children: [
            Expanded(
              child: _statTile(isDark, 'Total days', '${attendance.totalDays}'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(
                isDark,
                'Present',
                '${attendance.presentDays}',
                valueColor: AppTheme.statusSuccess,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(
                isDark,
                'Absent',
                '${attendance.absentDays}',
                valueColor: AppTheme.statusError,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _statTile(isDark, 'Leave', '${attendance.leaveDays}'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(
                isDark,
                'Half days',
                '${attendance.halfDays}',
                valueColor: AppTheme.statusWarning,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(isDark, 'Attendance', '$percent%'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _statTile(
                isDark,
                'Avg check-in',
                attendance.averageCheckin,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(
                isDark,
                'Avg check-out',
                attendance.averageCheckout,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _statTile(
          isDark,
          'Avg working hours',
          attendance.averageWorkingHours,
        ),
      ],
    );
  }

  Widget _buildBreaksCard(bool isDark, EmployeeDashboardBreaks breaks) {
    final showBreak4 = breaks.averageBreak4PlusMinutes > 0;
    return _section(
      isDark: isDark,
      title: 'Breaks',
      children: [
        Row(
          children: [
            Expanded(child: _statTile(isDark, 'Break 1', breaks.averageBreak1)),
            const SizedBox(width: 8),
            Expanded(child: _statTile(isDark, 'Break 2', breaks.averageBreak2)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _statTile(isDark, 'Break 3', breaks.averageBreak3)),
            if (showBreak4) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _statTile(isDark, 'Break 4+', breaks.averageBreak4Plus),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _statTile(
                isDark,
                'Avg total break',
                breaks.averageTotalBreak,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(
                isDark,
                'Avg / day',
                breaks.averageBreaksPerDay % 1 == 0
                    ? breaks.averageBreaksPerDay.toInt().toString()
                    : breaks.averageBreaksPerDay.toStringAsFixed(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _statTile(isDark, 'Longest', breaks.longestBreak),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(isDark, 'Total breaks', '${breaks.totalBreaks}'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _section({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _card({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: child,
    );
  }

  Widget _statTile(
    bool isDark,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ??
                  (isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }

  String _prettyDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return _displayFormat.format(parsed);
  }

  String _prettyTime(String value) {
    if (value.isEmpty) return '-';
    final parts = value.split(':');
    if (parts.length < 2) return value;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value;
    return DateFormat('hh:mm a').format(DateTime(2000, 1, 1, hour, minute));
  }
}
