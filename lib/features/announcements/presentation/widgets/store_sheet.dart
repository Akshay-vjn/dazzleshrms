import 'announcement_selection_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List.from(widget.selectedStoreIds);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storesAsync = ref.watch(storesProvider);

    return AnnouncementSelectionSurface(
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Select Stores",
                    style: theme.textTheme.titleMedium,
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
          Divider(height: 1, thickness: .5, color: theme.dividerColor),

          // LIST
          Expanded(
            child: storesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  CheckboxListTile(
                    title: const Text("All Stores"),
                    selected: _tempSelectedIds.isEmpty,
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
                      selected: _tempSelectedIds.contains(s.storeId),
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
