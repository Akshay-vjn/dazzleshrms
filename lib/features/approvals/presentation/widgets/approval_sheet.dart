import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_theme/app_theme.dart';

class ApprovalSheet extends StatefulWidget {
  final String employeeName;
  final String fromDate;
  final String toDate;
  final Function(Map<DateTime, bool> decisions, String? reason) onSubmitted;

  const ApprovalSheet({
    super.key,
    required this.employeeName,
    required this.fromDate,
    required this.toDate,
    required this.onSubmitted,
  });

  @override
  State<ApprovalSheet> createState() => _ApprovalSheetState();
}

class _ApprovalSheetState extends State<ApprovalSheet> {
  late Map<DateTime, bool> daySelections;
  late List<DateTime> allDays;
  final TextEditingController reasonCtrl = TextEditingController();
  int? _selectedQuickReasonIndex;

  static const List<String> _quickRejectReasons = [
    "Leave Rejected: Not approved due to current work requirements.",
    "Leave Rejected: Unable to approve for the requested dates.",
    "Leave Rejected: Not approved due to team availability constraints.",
    "Leave Rejected: Kindly apply for alternate dates.",
    "Leave Rejected: Not approved as per company policy.",
  ];

  @override
  void initState() {
    super.initState();
    final start = DateTime.parse(widget.fromDate);
    final end = DateTime.parse(widget.toDate);
    allDays = _getDaysInRange(start, end);
    daySelections = {for (var day in allDays) day: true};
    reasonCtrl.addListener(_onReasonTextChanged);
  }

  @override
  void dispose() {
    reasonCtrl.removeListener(_onReasonTextChanged);
    reasonCtrl.dispose();
    super.dispose();
  }

  List<DateTime> _getDaysInRange(DateTime from, DateTime to) {
    List<DateTime> days = [];
    for (int i = 0; i <= to.difference(from).inDays; i++) {
      days.add(from.add(Duration(days: i)));
    }
    return days;
  }

  bool get _hasRejectedDays => daySelections.values.any((isApproved) => !isApproved);

  void _onReasonTextChanged() {
    if (_selectedQuickReasonIndex != null) {
      final selectedText = _quickRejectReasons[_selectedQuickReasonIndex!];
      if (reasonCtrl.text != selectedText) {
        setState(() => _selectedQuickReasonIndex = null);
      }
    }
  }

  void _onQuickReasonToggled(int index) {
    setState(() {
      if (_selectedQuickReasonIndex == index) {
        _selectedQuickReasonIndex = null;
        reasonCtrl.clear();
      } else {
        _selectedQuickReasonIndex = index;
        reasonCtrl.text = _quickRejectReasons[index];
        reasonCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: reasonCtrl.text.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Approval",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.PrimaryColor.withOpacity(0.12),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppTheme.PrimaryColor,
                  splashRadius: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 10),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allDays.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                    itemBuilder: (context, index) {
                      final day = allDays[index];
                      final isApproved = daySelections[day]!;

                      return SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          DateFormat('EEEE, d MMM yyyy').format(day),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          isApproved ? "Approved" : "Rejected",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isApproved ? AppTheme.statusSuccess : AppTheme.statusError,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: isApproved,
                        activeColor: AppTheme.statusSuccess,
                        inactiveThumbColor: AppTheme.statusError,
                        inactiveTrackColor: AppTheme.statusError.withOpacity(0.2),
                        onChanged: (val) => setState(() => daySelections[day] = val),
                      );
                    },
                  ),
                  if (_hasRejectedDays) ...[
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rejection Reason",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: reasonCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: "Enter reason for rejection",
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    if (_hasRejectedDays && reasonCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a reason for rejection"),
                          backgroundColor: AppTheme.statusError,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    widget.onSubmitted(daySelections, _hasRejectedDays ? reasonCtrl.text.trim() : null);
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
