import 'announcement_selection_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/announcement_provider.dart';

class EmployeeSheet extends ConsumerStatefulWidget {
  final List<int>? storeIds;
  final List<int>? designationIds;
  final List<int> selectedEmployeeIds;
  final Function(List<int>, List<String>) onSelect;

  const EmployeeSheet({
    super.key,
    this.storeIds,
    this.designationIds,
    required this.selectedEmployeeIds,
    required this.onSelect,
  });

  @override
  ConsumerState<EmployeeSheet> createState() => _EmployeeSheetState();
}

class _EmployeeSheetState extends ConsumerState<EmployeeSheet> {
  final searchCtrl = TextEditingController();
  String query = '';
  late List<int> _tempSelectedIds;

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List.from(widget.selectedEmployeeIds);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final storeKey = (widget.storeIds ?? []).join(',');
    final designationKey = (widget.designationIds ?? []).join(',');
    final employeesAsync = ref.watch(
      employeesByStoreAndDesignationProvider('$storeKey|$designationKey'),
    );

    return AnnouncementSelectionSurface(
      heightFraction: .75,
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
                    "Select Employees",
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final allEmployees = employeesAsync.value ?? [];
                    widget.onSelect(
                      _tempSelectedIds,
                      allEmployees
                          .where((e) => _tempSelectedIds.contains(e.employeeId))
                          .map((e) => e.employeeName)
                          .toList(),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Done"),
                ),
              ],
            ),
          ),

          // SEARCH
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          searchCtrl.clear();
                          setState(() => query = '');
                        },
                      )
                    : null,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) => setState(() => query = v.toLowerCase()),
            ),
          ),

          Divider(height: 1, thickness: .5, color: theme.dividerColor),

          // LIST
          Expanded(
            child: employeesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                final filtered = query.isEmpty
                    ? list
                    : list
                          .where(
                            (e) => e.employeeName.toLowerCase().contains(query),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No employees found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return CheckboxListTile(
                        title: const Text("All Employees"),
                        selected: _tempSelectedIds.isEmpty,
                        value: _tempSelectedIds.isEmpty,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _tempSelectedIds.clear();
                            }
                          });
                        },
                      );
                    }
                    final e = filtered[index - 1];
                    return CheckboxListTile(
                      title: Text(e.employeeName),
                      selected: _tempSelectedIds.contains(e.employeeId),
                      value: _tempSelectedIds.contains(e.employeeId),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _tempSelectedIds.add(e.employeeId);
                          } else {
                            _tempSelectedIds.remove(e.employeeId);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }
}
