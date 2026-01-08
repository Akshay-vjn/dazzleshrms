import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme/app_theme.dart';
import '../../data/providers/announcement_provider.dart';

class StoreSheet extends ConsumerWidget {
  final int? selectedStoreId;
  final Function(int?, String?) onSelect;

  const StoreSheet({
    super.key,
    required this.selectedStoreId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stores = ref.watch(storesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Store",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),

          // LIST
          Expanded(
            child: stores.when(
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => ListView(
                children: [
                  ListTile(
                    title: const Text("All Stores"),
                    trailing: selectedStoreId == null
                        ? const Icon(Icons.check, size: 20)
                        : null,
                    onTap: () {
                      onSelect(null, null);
                      Navigator.pop(context);
                    },
                  ),
                  ...list.map(
                        (s) => ListTile(
                      title: Text(s.storeName),
                      trailing: selectedStoreId == s.storeId
                          ? const Icon(Icons.check, size: 20)
                          : null,
                      onTap: () {
                        onSelect(s.storeId, s.storeName);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
