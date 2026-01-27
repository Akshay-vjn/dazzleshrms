import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme/app_theme.dart';
import '../../../approvals/data/models/designation_model.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final designationsAsync = ref.watch(designationsProvider);

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
                  "Select Designations",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final allDesignations = designationsAsync.value ?? [];
                    widget.onSelect(
                      _tempSelectedIds,
                      allDesignations
                          .where((d) => _tempSelectedIds.contains(d.designationId))
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
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),

          // LIST
          Expanded(
            child: designationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => ListView(
                children: [
                  CheckboxListTile(
                    title: const Text("All Designations"),
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
