import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme/app_theme.dart';
import '../../data/providers/announcement_provider.dart';

class EmployeeSheet extends ConsumerStatefulWidget {
  final int? storeId;
  final List<int> selectedEmployeeIds;
  final Function(List<int>, List<String>) onSelect;

  const EmployeeSheet({
    super.key,
    this.storeId,
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
    final isDark = theme.brightness == Brightness.dark;
    
    final employeesAsync = widget.storeId == null
        ? ref.watch(allEmployeesProvider)
        : ref.watch(employeesProvider(widget.storeId!));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                  "Select Employees",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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
                fillColor: isDark
                    ? AppTheme.surfaceBlack
                    : AppTheme.surfaceLight,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) => setState(() => query = v.toLowerCase()),
            ),
          ),

          Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),

          // LIST
          Expanded(
            child: employeesAsync.when(
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                final filtered = query.isEmpty
                    ? list
                    : list
                    .where(
                      (e) => e.employeeName
                      .toLowerCase()
                      .contains(query),
                )
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No employees found"));
                }

                return ListView(
                  children: [
                    CheckboxListTile(
                      title: const Text("All Employees"),
                      value: _tempSelectedIds.isEmpty,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _tempSelectedIds.clear();
                          }
                        });
                      },
                    ),
                    ...filtered.map(
                      (e) => CheckboxListTile(
                        title: Text(e.employeeName),
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
                      ),
                    ),
                  ],
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
