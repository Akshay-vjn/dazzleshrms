import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:dazzleshrms/core/app_theme/glass_surface.dart';
import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const NotificationTile({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppVisuals.of(context);

    return GlassSurface(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        titleAlignment: ListTileTitleAlignment.center,
        leading: Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.accentSurface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: colors.accent),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.text,
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.text),
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.muted),
            ),
          ],
        ),
        onTap: () {
          // TODO: mark as read / open detail
        },
      ),
    );
  }
}
