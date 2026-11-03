import 'package:dazzleshrms/core/app_theme/glass_surface.dart';
import 'package:flutter/material.dart';

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
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;

    return GlassSurface(
      padding: const EdgeInsets.all(16),

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
                  color: iconColor == null
                      ? theme.colorScheme.primaryContainer
                      : effectiveIconColor.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 24),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        Text(date, style: theme.textTheme.bodySmall),
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

          if (extra != null) ...[const SizedBox(height: 8), extra!],

          if (footer != null) ...[const SizedBox(height: 12), footer!],
        ],
      ),
    );
  }
}
