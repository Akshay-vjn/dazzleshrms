import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_theme/app_theme.dart';
import '../../../leave/data/models/blocked_date_model.dart';
import '../../../leave/data/providers/blocked_date_provider.dart';
import '../../../leave/data/providers/leave_type_provider.dart';
import '../../../leave/data/models/leave_type_model.dart';
import '../../data/provider/employee_leave_provider.dart';


class ApplyEmployeeLeaveFormSheet extends ConsumerStatefulWidget {
  final int employeeId;
  const ApplyEmployeeLeaveFormSheet({super.key, required this.employeeId});

  @override
  ConsumerState<ApplyEmployeeLeaveFormSheet> createState() =>
      _ApplyEmployeeLeaveFormSheetState();
}

class _ApplyEmployeeLeaveFormSheetState
    extends ConsumerState<ApplyEmployeeLeaveFormSheet> {
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
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final blockedAsync = ref.watch(blockedDateProvider);

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: blockedAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(e.toString()),
                    ),
                    data: (blockedDates) {
                      final Map<DateTime, BlockedDateModel> blockedMap = {
                        for (final b in blockedDates)
                          DateTime(b.date.year, b.date.month, b.date.day): b
                      };

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Select Date",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            const Divider(),

                            const SizedBox(height: 8),

                            Flexible(
                              child: TableCalendar(
                                firstDay: DateTime.now(),
                                lastDay: DateTime(2100),
                                focusedDay: DateTime.now(),

                                rowHeight: 38,

                                headerStyle: const HeaderStyle(
                                  titleCentered: true,
                                  formatButtonVisible: false,
                                ),

                                calendarStyle: CalendarStyle(
                                  todayDecoration: BoxDecoration(
                                    color: AppTheme.PrimaryColor.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: AppTheme.PrimaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  outsideDaysVisible: false,
                                ),

                                calendarBuilders: CalendarBuilders(
                                  defaultBuilder: (context, day, _) {
                                    final d = DateTime(day.year, day.month, day.day);

                                    if (blockedMap.containsKey(d)) {
                                      return Container(
                                        margin: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade500,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${day.day}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
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
                                        title: const Text("Blocked Date"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Date: ${_formatDate(blocked.date)}"),
                                            const SizedBox(height: 8),
                                            Text("Reason: ${blocked.reason}"),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
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
                                      if (selectedLeaveTypeName?.toLowerCase() == 'hdi' ||
                                          selectedLeaveTypeName?.toLowerCase() == 'hdo') {
                                        toDate = selectedDay;
                                      }
                                    } else {
                                      toDate = selectedDay;
                                      if (selectedLeaveTypeName?.toLowerCase() == 'hdi' ||
                                          selectedLeaveTypeName?.toLowerCase() == 'hdo') {
                                        fromDate = selectedDay;
                                      }
                                    }
                                  });

                                  Navigator.pop(context);
                                },
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
    ref.read(applyEmployeeLeaveProvider(widget.employeeId).notifier).applyLeave(
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
    final applyLeaveState = ref.watch(applyEmployeeLeaveProvider(widget.employeeId));

    ref.listen<AsyncValue<void>>(
      applyEmployeeLeaveProvider(widget.employeeId),
          (previous, next) {
        next.whenOrNull(
          error: (error, _) {
            _showSheetSnackBar(error.toString());
          },
          data: (_) {
            if (previous is AsyncLoading) {
               _showSheetSnackBar(
                "Leave applied successfully",
                isError: false,
              );

              ref.read(employeeLeavesProvider(widget.employeeId).notifier).loadLeaves();
              ref.invalidate(usedLeavesFamilyProvider(widget.employeeId));

              Future.delayed(const Duration(milliseconds: 800), () {
                if (context.mounted) Navigator.pop(context);
              });
            }
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
                                
                                if (selectedLeaveTypeName?.toLowerCase() == 'hdi' ||
                                    selectedLeaveTypeName?.toLowerCase() == 'hdo') {
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
                        decoration: const InputDecoration(
                          hintText: "Enter reason",
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
