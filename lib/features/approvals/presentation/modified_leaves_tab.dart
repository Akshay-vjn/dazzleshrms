import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/data/providers/dashboard_provider.dart';
import '../data/providers/changed_leave_provider.dart';
import '../data/providers/changedtab_actions_provider.dart';
import '../data/models/designation_model.dart';
import '../../announcements/data/models/store_model.dart';
import '../data/providers/approvals_provider.dart';

class ChangedLeavesTab extends ConsumerStatefulWidget {
  const ChangedLeavesTab({super.key});

  @override
  ConsumerState<ChangedLeavesTab> createState() =>
      _ChangedLeavesTabState();
}

class _ChangedLeavesTabState
    extends ConsumerState<ChangedLeavesTab> {
  int _page = 1;
  final int _limit = 10;
  int? _selectedDesignationId;
  int? _selectedStoreId;
  String? _selectedDesignationName;
  String? _selectedStoreName;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    _page = 1;
    await ref.read(pendingLeaveProvider.notifier).loadPendingLeaves(
      page: _page,
      limit: _limit,
      designationId: _selectedDesignationId,
      storeId: _selectedStoreId,
    );
  }

  void _onFilterChanged() {
    _page = 1;
    ref.read(pendingLeaveProvider.notifier).loadPendingLeaves(
      page: _page,
      limit: _limit,
      designationId: _selectedDesignationId,
      storeId: _selectedStoreId,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedDesignationId = null;
      _selectedStoreId = null;
      _selectedDesignationName = null;
      _selectedStoreName = null;
    });
    _onFilterChanged();
  }

  void _showDesignationPicker() async {
    final designationsAsync = ref.read(designationProvider);

    await designationsAsync.when(
      data: (designations) async {
        final result = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _SearchableListSheet(
            title: "Select Designation",
            items: designations,
            selectedId: _selectedDesignationId,
            getItemId: (item) => item.designationId,
            getItemName: (item) => item.designation,
          ),
        );

        if (result != null) {
          setState(() {
            _selectedDesignationId = result['id'];
            _selectedDesignationName = result['name'];
          });
          _onFilterChanged();
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  void _showStorePicker() async {
    final storesAsync = ref.read(storeProvider);

    await storesAsync.when(
      data: (stores) async {
        final result = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _SearchableListSheet(
            title: "Select Store",
            items: stores,
            selectedId: _selectedStoreId,
            getItemId: (item) => item.storeId,
            getItemName: (item) => item.storeName,
          ),
        );

        if (result != null) {
          setState(() {
            _selectedStoreId = result['id'];
            _selectedStoreName = result['name'];
          });
          _onFilterChanged();
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  Widget _buildFilters() {
    final hasActiveFilters = _selectedDesignationId != null || _selectedStoreId != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Filters",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: const Text("Clear All"),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _FilterChip(
                  label: "Designation",
                  selectedValue: _selectedDesignationName,
                  onTap: _showDesignationPicker,
                  onClear: _selectedDesignationId != null
                      ? () {
                    setState(() {
                      _selectedDesignationId = null;
                      _selectedDesignationName = null;
                    });
                    _onFilterChanged();
                  }
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterChip(
                  label: "Store",
                  selectedValue: _selectedStoreName,
                  onTap: _showStorePicker,
                  onClear: _selectedStoreId != null
                      ? () {
                    setState(() {
                      _selectedStoreId = null;
                      _selectedStoreName = null;
                    });
                    _onFilterChanged();
                  }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _confirmAction({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pendingLeaveProvider);

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: state.when(
            loading: () =>
            const Center(child: CircularProgressIndicator()),

            error: (e, _) =>
                Center(child: Text(e.toString())),

            data: (data) {
              if (data == null || data.records.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(child: Text("No changed leaves")),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: data.records.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = data.records[i];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.date,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                          ),

                          const SizedBox(height: 6),

                          Text(
                            item.employeeName,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Store: ${item.storeName}",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          if (item.designation != null)
                            Text(
                              "Designation:${item.designation}",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Text(
                                item.changesFrom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                item.changesTo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Days Taken: ${item.daysTaken}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    _confirmAction(
                                      context: context,
                                      title: "Reject Change",
                                      message:
                                      "Reject this leave modification request?",
                                      onConfirm: () async {
                                        try {
                                          final res = await ref
                                              .read(
                                            changedTabRepositoryProvider,
                                          )
                                              .rejectChange(item.logId);

                                          if (!mounted) return;

                                          _showSnack(
                                            context,
                                            res.message,
                                            Colors.red,
                                          );

                                          _refresh();
                                          ref.read(dashboardProvider.notifier).loadDashboard();
                                        } catch (e) {
                                          _showSnack(
                                            context,
                                            e
                                                .toString()
                                                .replaceFirst(
                                              'Exception: ',
                                              '',
                                            ),
                                            Colors.red,
                                          );
                                        }
                                      },
                                    );
                                  },
                                  child: const Text("Reject"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {
                                    _confirmAction(
                                      context: context,
                                      title: "Approve Change",
                                      message:
                                      "Approve this leave modification request?",
                                      onConfirm: () async {
                                        try {
                                          final res = await ref
                                              .read(
                                            changedTabRepositoryProvider,
                                          )
                                              .approveChange(item.logId);

                                          if (!mounted) return;

                                          _showSnack(
                                            context,
                                            res.message,
                                            Colors.green,
                                          );

                                          _refresh();
                                          ref.read(dashboardProvider.notifier).loadDashboard();
                                        } catch (e) {
                                          _showSnack(
                                            context,
                                            e
                                                .toString()
                                                .replaceFirst(
                                              'Exception: ',
                                              '',
                                            ),
                                            Colors.red,
                                          );
                                        }
                                      },
                                    );
                                  },
                                  child: const Text("Approve"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Custom Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    required this.selectedValue,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedValue ?? "All",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              )
            else
              Icon(
                Icons.arrow_drop_down_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
          ],
        ),
      ),
    );
  }
}

// Searchable List Bottom Sheet
class _SearchableListSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final int? selectedId;
  final int Function(T) getItemId;
  final String Function(T) getItemName;

  const _SearchableListSheet({
    required this.title,
    required this.items,
    required this.selectedId,
    required this.getItemId,
    required this.getItemName,
  });

  @override
  State<_SearchableListSheet<T>> createState() => _SearchableListSheetState<T>();
}

class _SearchableListSheetState<T> extends State<_SearchableListSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) =>
            widget.getItemName(item).toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // "All" option
          ListTile(
            leading: Radio<int?>(
              value: null,
              groupValue: widget.selectedId,
              onChanged: (_) {
                Navigator.pop(context, {'id': null, 'name': null});
              },
            ),
            title: Text(
              "All ${widget.title}s",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: widget.selectedId == null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            onTap: () {
              Navigator.pop(context, {'id': null, 'name': null});
            },
          ),

          const Divider(height: 1),

          // List
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No results found",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final itemId = widget.getItemId(item);
                final itemName = widget.getItemName(item);
                final isSelected = itemId == widget.selectedId;

                return ListTile(
                  leading: Radio<int>(
                    value: itemId,
                    groupValue: widget.selectedId,
                    onChanged: (_) {
                      Navigator.pop(context, {'id': itemId, 'name': itemName});
                    },
                  ),
                  title: Text(
                    itemName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, {'id': itemId, 'name': itemName});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
