import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_theme/app_theme.dart';
import 'data/models/apply_leave_model.dart';
import 'data/models/leave_type_model.dart';
import 'data/models/blocked_date_model.dart';
import 'data/providers/apply_leave_provider.dart';
import 'data/providers/leave_type_provider.dart';
import 'data/providers/blocked_date_provider.dart';
import 'data/providers/leave_provider.dart';
import '../dashboard/data/providers/dashboard_provider.dart';

class ApplyLeaveFormSheet extends ConsumerStatefulWidget {
  const ApplyLeaveFormSheet({super.key});

  @override
  ConsumerState<ApplyLeaveFormSheet> createState() =>
      _ApplyLeaveFormSheetState();
}

class _ApplyLeaveFormSheetState
    extends ConsumerState<ApplyLeaveFormSheet> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController reasonCtrl = TextEditingController();

  int? selectedLeaveTypeId;
  String? selectedLeaveTypeName;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveTypeProvider.notifier).loadLeaveTypes();
    });
  }


  void _showSheetSnackBar(
      String message, {
        bool isError = true,
      }) {
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          isError ? AppTheme.statusError : AppTheme.statusSuccess,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  String _formatDate(DateTime date) =>
      date.toIso8601String().split('T').first;

  String _formatDisplayDate(DateTime date) =>
      DateFormat('dd-MM-yyyy').format(date);


  Future<void> _pickDate({required bool isFrom}) async {
    ref.invalidate(blockedDateProvider);

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final blockedAsync = ref.watch(blockedDateProvider);
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Dialog(
            backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                    maxWidth: 380,
                  ),
                  child: blockedAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(e.toString()),
                    ),
                    data: (blockedDates) {
                      final Map<DateTime, BlockedDateModel> blockedMap = {
                        for (final b in blockedDates)
                          DateTime(b.date.year, b.date.month, b.date.day): b
                      };

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isFrom ? "Select From Date" : "Select To Date",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => Navigator.pop(context),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: theme.dividerColor.withOpacity(0.5),
                          ),

                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                              child: TableCalendar(
                                firstDay: DateTime.now(),
                                lastDay: DateTime(2100),
                                focusedDay: DateTime.now(),
                                daysOfWeekHeight: 28,
                                rowHeight: 42,
                                sixWeekMonthsEnforced: false,
                                shouldFillViewport: false,

                                headerStyle: HeaderStyle(
                                  titleCentered: true,
                                  formatButtonVisible: false,
                                  titleTextStyle: theme.textTheme.titleSmall!
                                      .copyWith(fontWeight: FontWeight.w600),
                                  leftChevronIcon: Icon(
                                    Icons.chevron_left_rounded,
                                    color: AppTheme.PrimaryColor,
                                  ),
                                  rightChevronIcon: Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.PrimaryColor,
                                  ),
                                  headerPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                                  decoration: const BoxDecoration(),
                                ),

                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: theme.textTheme.labelSmall!
                                      .copyWith(
                                    color: theme.hintColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  weekendStyle: theme.textTheme.labelSmall!
                                      .copyWith(
                                    color: theme.hintColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  cellMargin: const EdgeInsets.all(4),
                                  defaultTextStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  weekendTextStyle: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.error
                                        .withOpacity(0.85),
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: AppTheme.PrimaryColor
                                        .withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.PrimaryColor,
                                      width: 1.2,
                                    ),
                                  ),
                                  todayTextStyle: const TextStyle(
                                    color: AppTheme.PrimaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  selectedDecoration: BoxDecoration(
                                    color: AppTheme.PrimaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.PrimaryColor
                                            .withOpacity(0.35),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  selectedTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                calendarBuilders: CalendarBuilders(
                                  defaultBuilder: (context, day, _) {
                                    final d = DateTime(
                                        day.year, day.month, day.day);

                                    if (blockedMap.containsKey(d)) {
                                      return Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.statusError
                                              .withOpacity(0.9),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${day.day}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    }
                                    return null;
                                  },
                                ),

                                onDaySelected: (selectedDay, _) {
                                  final d = DateTime(
                                    selectedDay.year,
                                    selectedDay.month,
                                    selectedDay.day,
                                  );

                                  //  BLOCKED DATE
                                  if (blockedMap.containsKey(d)) {
                                    final blocked = blockedMap[d]!;

                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                        icon: const Icon(
                                          Icons.event_busy_rounded,
                                          color: AppTheme.statusError,
                                        ),
                                        title: const Text("Blocked Date"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Date: ${_formatDate(blocked.date)}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 6),
                                            Text("Reason: ${blocked.reason}"),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    if (isFrom) {
                                      fromDate = selectedDay;
                                      final type = selectedLeaveTypeName
                                          ?.toLowerCase()
                                          .trim();
                                      if (type == 'hdi' ||
                                          type == 'hdo' ||
                                          type == 'half day in' ||
                                          type == 'half day out') {
                                        toDate = selectedDay;
                                      }
                                    } else {
                                      toDate = selectedDay;
                                      final type = selectedLeaveTypeName
                                          ?.toLowerCase()
                                          .trim();
                                      if (type == 'hdi' ||
                                          type == 'hdo' ||
                                          type == 'half day in' ||
                                          type == 'half day out') {
                                        fromDate = selectedDay;
                                      }
                                    }
                                  });

                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }


  void _submitLeave() {
    if (selectedLeaveTypeId == null ||
        fromDate == null ||
        toDate == null ||
        reasonCtrl.text.trim().isEmpty) {
      _showSheetSnackBar("Please fill all fields");
      return;
    }
    ref.read(applyLeaveProvider.notifier).applyLeave(
      leaveTypeId: selectedLeaveTypeId!,
      fromDate: _formatDate(fromDate!),
      toDate: _formatDate(toDate!),
      note: reasonCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leaveTypeState = ref.watch(leaveTypeProvider);
    final applyLeaveState = ref.watch(applyLeaveProvider);

    ref.listen<AsyncValue<ApplyLeaveResponse?>>(
      applyLeaveProvider,
          (previous, next) {
        next.whenOrNull(
          error: (error, _) {
            _showSheetSnackBar(error.toString());
          },
          data: (_) {
            _showSheetSnackBar(
              "Leave applied successfully",
              isError: false,
            );

            ref.read(leaveProvider.notifier).loadLeaves();
            ref.read(dashboardProvider.notifier).loadDashboard();
            ref.invalidate(usedLeavesProvider);

            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) Navigator.pop(context);
            });
          },
        );
      },
    );

    return AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: ScaffoldMessenger(
            key: _messengerKey,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "New Leave Request",
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text("Leave Type", style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),

                          leaveTypeState.when(
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child:
                                CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            error: (e, _) => Text(
                              e.toString(),
                              style:
                              const TextStyle(color: Colors.red),
                            ),
                            data: (types) {
                              return DropdownButtonFormField<int>(
                                value: selectedLeaveTypeId,
                                hint: const Text("Select leave type"),
                                decoration: InputDecoration(
                                  fillColor: theme.brightness == Brightness.dark
                                      ? AppTheme.surfaceDark
                                      : null,
                                ),
                                items: types
                                    .map(
                                      (LeaveType e) =>
                                      DropdownMenuItem<int>(
                                        value: e.leaveId,
                                        child: Text(e.leaveType),
                                      ),
                                )
                                    .toList(),
                                onChanged: (v) {
                                  final selectedType = types.firstWhere((e) => e.leaveId == v);
                                  setState(() {
                                    selectedLeaveTypeId = v;
                                    selectedLeaveTypeName = selectedType.leaveType;

                                    final type = selectedLeaveTypeName?.toLowerCase().trim();
                                    if (type == 'hdi' ||
                                        type == 'hdo' ||
                                        type == 'half day in' ||
                                        type == 'half day out') {
                                      if (fromDate != null) {
                                        toDate = fromDate;
                                      } else if (toDate != null) {
                                        fromDate = toDate;
                                      }
                                    }
                                  });
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          Text(
                            "Leave Duration",
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _pickDate(isFrom: true),
                                  child: Text(
                                    fromDate == null
                                        ? "From Date"
                                        : _formatDisplayDate(fromDate!),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _pickDate(isFrom: false),
                                  child: Text(
                                    toDate == null
                                        ? "To Date"
                                        : _formatDisplayDate(toDate!),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Text("Reason", style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),

                          TextField(
                            controller: reasonCtrl,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: "Enter reason",
                              fillColor: theme.brightness == Brightness.dark
                                  ? AppTheme.surfaceDark
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: applyLeaveState.isLoading
                            ? null
                            : _submitLeave,
                        child: applyLeaveState.isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                            : const Text("Submit Leave"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    reasonCtrl.dispose();
    super.dispose();
  }
}