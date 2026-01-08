import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme/app_theme.dart';
import '../../data/providers/announcement_provider.dart';

class EmployeeSheet extends ConsumerStatefulWidget {
  final int storeId;
  final int? selectedEmployeeId;
  final Function(int?, String?) onSelect;

  const EmployeeSheet({
    super.key,
    required this.storeId,
    required this.selectedEmployeeId,
    required this.onSelect,
  });

  @override
  ConsumerState<EmployeeSheet> createState() => _EmployeeSheetState();
}

class _EmployeeSheetState extends ConsumerState<EmployeeSheet> {
  final searchCtrl = TextEditingController();
  String query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final employees = ref.watch(employeesProvider(widget.storeId));

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
                  "Select Employee",
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
                    ? AppTheme.surfaceDarkVariant
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
            child: employees.when(
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
                    ListTile(
                      title: const Text("All Employees"),
                      trailing: widget.selectedEmployeeId == null
                          ? const Icon(Icons.check, size: 20)
                          : null,
                      onTap: () {
                        widget.onSelect(null, null);
                        Navigator.pop(context);
                      },
                    ),
                    ...filtered.map(
                          (e) => ListTile(
                        title: Text(e.employeeName),
                        trailing:
                        widget.selectedEmployeeId == e.employeeId
                            ? const Icon(Icons.check, size: 20)
                            : null,
                        onTap: () {
                          widget.onSelect(
                              e.employeeId, e.employeeName);
                          Navigator.pop(context);
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
