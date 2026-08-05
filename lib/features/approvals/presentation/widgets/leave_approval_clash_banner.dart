import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_theme/app_theme.dart';
import '../../data/models/leave_approval_clash_model.dart';

class LeaveApprovalClashBanner extends StatelessWidget {
  final LeaveApprovalClashResponse clashData;

  const LeaveApprovalClashBanner({super.key, required this.clashData});

  Color _statusColor(double percentage, String status) {
    if (percentage >= 50) {
      return AppTheme.statusError; // Red (50 and above)
    } else if (percentage >= 30) {
      return AppTheme.statusWarning; // Orange (30 to 50)
    }
    // Fallback based on status string if percentage is < 30
    switch (status.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return AppTheme.statusError;
      case 'MEDIUM':
      case 'WARNING':
        return AppTheme.statusWarning;
      case 'SAFE':
      default:
        return AppTheme.statusSuccess; // Green (below 30)
    }
  }

  IconData _statusIcon(double percentage, String status) {
    if (percentage >= 50) {
      return Icons.error_rounded;
    } else if (percentage >= 30) {
      return Icons.warning_amber_rounded;
    }
    switch (status.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return Icons.error_rounded;
      case 'MEDIUM':
      case 'WARNING':
        return Icons.warning_amber_rounded;
      case 'SAFE':
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = clashData.calendar.calendar;
    if (days.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Find the worst day among all days
    final worstDay = days.reduce((a, b) => a.percentage > b.percentage ? a : b);
    final bannerColor = _statusColor(worstDay.percentage, worstDay.status);
    final hasWarningOrCritical = worstDay.percentage >= 30 || worstDay.status.toUpperCase() != 'SAFE';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bannerColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _statusIcon(worstDay.percentage, worstDay.status),
                color: bannerColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasWarningOrCritical
                      ? 'Leave warning'
                      : 'Leave Info',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: bannerColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...days.map((day) {
            final color = _statusColor(day.percentage, day.status);
            final formattedDate = DateFormat('d MMM yyyy').format(day.date);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${day.leaveCount} on leave',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${day.percentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (day.leaveDetails.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: day.leaveDetails.map((detail) {
                          final initial = detail.employeeName.trim().isNotEmpty
                              ? detail.employeeName.trim()[0].toUpperCase()
                              : '?';

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
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
                                  radius: 9,
                                  backgroundColor:
                                      color.withOpacity(0.2),
                                  child: Text(
                                    initial,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    detail.employeeName.trim(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (detail.leaveType.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${detail.leaveType})',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 9,
                                      color: isDark
                                          ? AppTheme.textMutedDark
                                          : AppTheme.textMutedLight,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
