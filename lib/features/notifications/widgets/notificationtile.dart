import 'package:flutter/material.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';

class NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const NotificationTile({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.PrimaryColor.withOpacity(0.12),
              child: Icon(
                icon,
                color: AppTheme.PrimaryColor,
              )
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.statusError,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Text(message),
        trailing: Text(
          time,
          style: theme.textTheme.bodySmall,
        ),
        onTap: () {
          // TODO: mark as read / open detail
        },
      ),
    );
  }
}
