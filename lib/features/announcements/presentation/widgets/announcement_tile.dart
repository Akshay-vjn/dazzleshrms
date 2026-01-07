import 'package:flutter/material.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';

class AnnouncementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String date;
  final Color? iconColor;
  final Widget? extra;
  final Widget? footer;

  const AnnouncementTile({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.date,
    this.iconColor,
    this.extra,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppTheme.surfaceDarkVariant
            : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.PrimaryColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───────── HEADER ─────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? AppTheme.iconBgDark
                      : (iconColor ?? AppTheme.iconPrimary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppTheme.iconPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Date
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Message
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (extra != null) ...[
            const SizedBox(height: 8),
            extra!,
          ],

          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}
