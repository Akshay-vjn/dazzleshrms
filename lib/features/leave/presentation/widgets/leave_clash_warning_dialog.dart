import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_theme/app_theme.dart';
import '../../data/models/leave_clash_calendar_model.dart';

class LeaveClashWarningDialog extends StatelessWidget {
  final LeaveClashCalendarDay clash;

  const LeaveClashWarningDialog({super.key, required this.clash});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final isHigh = clash.percentage >= 50;
    final severityColor =
        isHigh ? AppTheme.statusError : AppTheme.statusWarning;
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(clash.date);
    final countLabel =
        '${clash.leaveCount} ${clash.leaveCount == 1 ? 'employee' : 'employees'} on leave';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with severity icon and title
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isHigh
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline_rounded,
                    color: severityColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHigh ? 'High Leave Volume' : 'Leave Availability Notice',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppTheme.textMutedDark
                              : AppTheme.textMutedLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Warning summary card with percentage bar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: severityColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        countLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: severityColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${clash.percentage.toStringAsFixed(0)}% of team',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (clash.percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: severityColor.withOpacity(0.15),
                      color: severityColor,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            if (clash.leaveDetails.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Employees on Leave',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.textMutedDark
                      : AppTheme.textMutedLight,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 140),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: clash.leaveDetails.map((item) {
                      final name = item.employeeName.trim();
                      final initial =
                          name.isNotEmpty ? name[0].toUpperCase() : '?';

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor:
                                  AppTheme.PrimaryColor.withOpacity(0.25),
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.PrimaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              name,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            // const SizedBox(height: 16),
            // Text(
            //   'You can still select this date if you wish to continue.',
            //   style: theme.textTheme.bodySmall?.copyWith(
            //     color: isDark
            //         ? AppTheme.textMutedDark
            //         : AppTheme.textMutedLight,
            //     fontStyle: FontStyle.italic,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Change Date'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: severityColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Select Date'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

