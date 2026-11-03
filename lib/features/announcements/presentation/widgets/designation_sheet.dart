import 'announcement_selection_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/announcement_provider.dart';

class DesignationSheet extends ConsumerStatefulWidget {
  final List<int> selectedDesignationIds;
  final Function(List<int>, List<String>) onSelect;

  const DesignationSheet({
    super.key,
    required this.selectedDesignationIds,
    required this.onSelect,
  });

  @override
  ConsumerState<DesignationSheet> createState() => _DesignationSheetState();
}

class _DesignationSheetState extends ConsumerState<DesignationSheet> {
  late List<int> _tempSelectedIds;

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List.from(widget.selectedDesignationIds);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designationsAsync = ref.watch(designationsProvider);

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
                    "Select Designations",
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final allDesignations = designationsAsync.value ?? [];
                    widget.onSelect(
                      _tempSelectedIds,
                      allDesignations
                          .where(
                            (d) => _tempSelectedIds.contains(d.designationId),
                          )
                          .map((d) => d.designation)
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
            child: designationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  CheckboxListTile(
                    title: const Text("All Designations"),
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
                    (d) => CheckboxListTile(
                      title: Text(d.designation),
                      selected: _tempSelectedIds.contains(d.designationId),
                      value: _tempSelectedIds.contains(d.designationId),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _tempSelectedIds.add(d.designationId);
                          } else {
                            _tempSelectedIds.remove(d.designationId);
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
