import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme/app_theme.dart';
import '../../data/providers/announcement_provider.dart';

class StoreSheet extends ConsumerStatefulWidget {
  final List<int> selectedStoreIds;
  final Function(List<int>, List<String>) onSelect;

  const StoreSheet({
    super.key,
    required this.selectedStoreIds,
    required this.onSelect,
  });

  @override
  ConsumerState<StoreSheet> createState() => _StoreSheetState();
}

class _StoreSheetState extends ConsumerState<StoreSheet> {
  late List<int> _tempSelectedIds;
  late List<String> _tempSelectedNames;

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List.from(widget.selectedStoreIds);
    _tempSelectedNames = [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final storesAsync = ref.watch(storesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                  "Select Stores",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final allStores = storesAsync.value ?? [];
                    widget.onSelect(
                      _tempSelectedIds,
                      allStores
                          .where((s) => _tempSelectedIds.contains(s.storeId))
                          .map((s) => s.storeName)
                          .toList(),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Done"),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),

          // LIST
          Expanded(
            child: storesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => ListView(
                children: [
                  CheckboxListTile(
                    title: const Text("All Stores"),
                    value: _tempSelectedIds.isEmpty,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _tempSelectedIds.clear();
                        }
                      });
                    },
                  ),
                  ...list.map(
                    (s) => CheckboxListTile(
                      title: Text(s.storeName),
                      value: _tempSelectedIds.contains(s.storeId),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _tempSelectedIds.add(s.storeId);
                          } else {
                            _tempSelectedIds.remove(s.storeId);
                          }
                        });
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
