import 'package:dazzleshrms/features/announcements/widgets/announcement_tile.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
      ),
    );
  }
}
