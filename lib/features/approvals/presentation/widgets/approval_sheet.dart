import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_theme/app_theme.dart';
import '../../data/providers/approvals_provider.dart';
import 'leave_approval_clash_banner.dart';

class ApprovalSheet extends ConsumerStatefulWidget {
  final int? leaveRoasterId;
  final String employeeName;
  final String fromDate;
  final String toDate;
  final Function(Map<DateTime, bool> decisions, String? reason) onSubmitted;

  const ApprovalSheet({
    super.key,
    this.leaveRoasterId,
    required this.employeeName,
    required this.fromDate,
    required this.toDate,
    required this.onSubmitted,
  });

  @override
  ConsumerState<ApprovalSheet> createState() => _ApprovalSheetState();
}

class _ApprovalSheetState extends ConsumerState<ApprovalSheet> {
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
    if (widget.leaveRoasterId != null) {
      Future.microtask(() {
        ref.invalidate(leaveApprovalClashProvider(widget.leaveRoasterId!));
      });
    }
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
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
                  if (widget.leaveRoasterId != null) ...[
                    Consumer(
                      builder: (context, ref, _) {
                        final clashAsync = ref.watch(
                          leaveApprovalClashProvider(widget.leaveRoasterId!),
                        );

                        return clashAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          error: (e, _) => const SizedBox.shrink(),
                          data: (clashData) =>
                              LeaveApprovalClashBanner(clashData: clashData),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
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
