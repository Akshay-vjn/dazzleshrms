import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:flutter/material.dart';

/// Clean swipeable range calendar in a bottom sheet.
/// Swipe left/right to change month, tap a start day, then an end day.
Future<DateTimeRange?> showBreakReportDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
}) {
  return showModalBottomSheet<DateTimeRange>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppVisuals.of(context).surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _CalendarSheet(
      firstDate: DateUtils.dateOnly(firstDate),
      lastDate: DateUtils.dateOnly(lastDate),
      initialDateRange: initialDateRange,
    ),
  );
}

const _months = ['January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'];
const _short = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class _CalendarSheet extends StatefulWidget {
  const _CalendarSheet({
    required this.firstDate,
    required this.lastDate,
    this.initialDateRange,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTimeRange? initialDateRange;

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  static const double _cell = 48;

  late final PageController _pages;
  late int _page;
  late final int _pageCount;
  DateTime? _start;
  DateTime? _end;

  DateTime _monthOf(int page) =>
      DateTime(widget.firstDate.year, widget.firstDate.month + page);

  int _pageOf(DateTime d) =>
      (d.year - widget.firstDate.year) * 12 + d.month - widget.firstDate.month;

  @override
  void initState() {
    super.initState();
    _pageCount = _pageOf(widget.lastDate) + 1;
    final init = widget.initialDateRange;
    if (init != null) {
      _start = DateUtils.dateOnly(init.start);
      _end = DateUtils.dateOnly(init.end);
    }
    final anchor = _start ?? DateUtils.dateOnly(DateTime.now());
    _page = _pageOf(anchor).clamp(0, _pageCount - 1);
    _pages = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int page) => _pages.animateToPage(
    page.clamp(0, _pageCount - 1),
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );

  void _onTap(DateTime day) {
    setState(() {
      if (_start == null || _end != null) {
        _start = day;
        _end = null;
      } else if (day.isBefore(_start!)) {
        _start = day;
      } else {
        _end = day;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppVisuals.of(context);
    final theme = Theme.of(context);
    final month = _monthOf(_page);
    final now = DateTime.now();
    final showToday = month.year != now.year || month.month != now.month;
    final days = (_start != null && _end != null)
        ? _end!.difference(_start!).inDays + 1
        : 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // From → To
            Row(
              children: [
                Expanded(
                  child: _DateLabel(
                    label: 'From',
                    date: _start,
                    active: _start == null || _end != null,
                  ),
                ),
                Container(width: 1, height: 44, color: colors.border),
                const SizedBox(width: 20),
                Expanded(
                  child: _DateLabel(
                    label: 'To',
                    date: _end,
                    active: _start != null && _end == null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Month title + arrows
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_months[month.month - 1]} ${month.year}',
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.text, fontWeight: FontWeight.w700),
                  ),
                ),
                if (showToday)
                  TextButton(
                    onPressed: () =>
                        _goTo(_pageOf(DateUtils.dateOnly(DateTime.now()))),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: colors.accent,
                    ),
                    child: const Text('Today'),
                  ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _page > 0 ? () => _goTo(_page - 1) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: colors.text,
                  disabledColor: colors.muted.withValues(alpha: 0.3),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed:
                  _page < _pageCount - 1 ? () => _goTo(_page + 1) : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: colors.text,
                  disabledColor: colors.muted.withValues(alpha: 0.3),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Weekday labels
            Row(
              children: [
                for (final w in _weekdays)
                  Expanded(
                    child: Center(
                      child: Text(w,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.muted,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Swipeable months (6 fixed rows so height never jumps)
            SizedBox(
              height: _cell * 6,
              child: PageView.builder(
                controller: _pages,
                itemCount: _pageCount,
                onPageChanged: (p) => setState(() => _page = p),
                itemBuilder: (_, p) => _MonthView(
                  month: _monthOf(p),
                  cell: _cell,
                  start: _start,
                  end: _end,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onTap: _onTap,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Single full-width action
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _start == null
                    ? null
                    : () => Navigator.pop(
                  context,
                  DateTimeRange(start: _start!, end: _end ?? _start!),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: Text(
                  _start == null
                      ? 'Select dates'
                      : days > 1
                      ? 'Apply · $days days'
                      : 'Apply',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({
    required this.label,
    required this.date,
    required this.active,
  });

  final String label;
  final DateTime? date;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = AppVisuals.of(context);
    final theme = Theme.of(context);
    final d = date;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelMedium?.copyWith(
                color: active ? colors.accent : colors.muted,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          d == null ? 'Select' : '${d.day} ${_short[d.month - 1]} ${d.year}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: d == null ? colors.muted : colors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.month,
    required this.cell,
    required this.start,
    required this.end,
    required this.firstDate,
    required this.lastDate,
    required this.onTap,
  });

  final DateTime month;
  final double cell;
  final DateTime? start;
  final DateTime? end;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppVisuals.of(context);
    final theme = Theme.of(context);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final offset = DateTime(month.year, month.month, 1).weekday - 1;
    final hasRange = start != null && end != null && start != end;
    final band = colors.accent.withValues(alpha: 0.10);

    Widget buildDay(int dayNum) {
      final day = DateTime(month.year, month.month, dayNum);
      final enabled = !day.isBefore(firstDate) && !day.isAfter(lastDate);
      final isStart = start != null && DateUtils.isSameDay(day, start);
      final isEnd = end != null && DateUtils.isSameDay(day, end);
      final selected = isStart || isEnd;
      final inRange = hasRange && day.isAfter(start!) && day.isBefore(end!);
      final leftBand = inRange || (hasRange && isEnd);
      final rightBand = inRange || (hasRange && isStart);
      final isToday = DateUtils.isSameDay(day, DateTime.now());

      Color textColor = colors.text;
      if (isToday) textColor = colors.accent;
      if (!enabled) textColor = colors.muted.withValues(alpha: 0.35);
      if (selected) textColor = theme.colorScheme.onPrimary;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onTap(day) : null,
        child: SizedBox(
          height: cell,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                          child: ColoredBox(
                              color: leftBand ? band : Colors.transparent)),
                      Expanded(
                          child: ColoredBox(
                              color: rightBand ? band : Colors.transparent)),
                    ],
                  ),
                ),
              ),
              Container(
                width: cell - 10,
                height: cell - 10,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? colors.accent : Colors.transparent,
                ),
                child: Text(
                  '$dayNum',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: selected || isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var r = 0; r < 6; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: () {
                    final n = r * 7 + c - offset + 1;
                    if (n < 1 || n > daysInMonth) {
                      return SizedBox(height: cell);
                    }
                    return buildDay(n);
                  }(),
                ),
            ],
          ),
      ],
    );
  }
}