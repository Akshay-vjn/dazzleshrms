import 'package:dazzleshrms/core/app_theme/app_surface.dart';
import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme/app_theme.dart';
import '../../dashboard/data/providers/dashboard_provider.dart';
import '../../break_reports/presentation/widgets/searchable_filter_sheet.dart'
    show FilterSheetScaffold;
import '../data/models/applied_leave_model.dart';
import '../data/providers/approvals_provider.dart';
import 'widgets/approval_sheet.dart';
import 'widgets/rejection_sheet.dart';
import 'package:intl/intl.dart';

class AppliedLeavesTab extends ConsumerStatefulWidget {
  const AppliedLeavesTab({super.key});

  @override
  ConsumerState<AppliedLeavesTab> createState() => _LeaveAppliedTabState();
}

class _LeaveAppliedTabState extends ConsumerState<AppliedLeavesTab> {
  int _page = 1;
  final int _limit = 10;
  int? _selectedDesignationId;
  int? _selectedStoreId;
  String? _selectedDesignationName;
  String? _selectedStoreName;

  @override
  void initState() {
    super.initState();
    ref
        .read(leaveApprovalProvider.notifier)
        .loadAppliedLeaves(
          page: _page,
          limit: _limit,
          designationId: _selectedDesignationId,
          storeId: _selectedStoreId,
        );
  }

  void _showPartialApprovalSheet(AppliedLeaveItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ApprovalSheet(
        leaveRoasterId: item.leaveRoasterId,
        employeeName: item.employeeName,
        fromDate: item.fromDate,
        toDate: item.toDate,
        onSubmitted: (decisions, reason) async {
          Navigator.pop(context);

          final apiDecisions = decisions.entries
              .map(
                (e) => {
                  "date": DateFormat('yyyy-MM-dd').format(e.key),
                  "action": e.value ? "APPROVE" : "REJECT",
                },
              )
              .toList();

          try {
            final res = await ref
                .read(leaveApprovalRepositoryProvider)
                .approveLeave(
                  leaveRoasterId: item.leaveRoasterId,
                  decisions: apiDecisions,
                  reason: reason,
                );
            _handleSuccess(res.message);
          } catch (e) {
            _handleError(e);
          }
        },
      ),
    );
  }

  void _handleSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.statusSuccess,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
    _refresh();
    ref.read(dashboardProvider.notifier).loadDashboard();
  }

  void _handleError(dynamic e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_extractErrorMessage(e)),
        backgroundColor: AppTheme.statusError,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showRejectSheet(AppliedLeaveItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RejectionSheet(
        employeeName: item.employeeName,
        onSubmitted: (reason) async {
          Navigator.pop(context);

          try {
            final res = await ref
                .read(leaveApprovalRepositoryProvider)
                .rejectLeave(
                  leaveRoasterId: item.leaveRoasterId,
                  reason: reason,
                );

            _handleSuccess(res.message);
          } catch (e) {
            _handleError(e);
          }
        },
      ),
    );
  }

  String _extractErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('message:')) {
      final regex = RegExp(r'message:\s*([^,}]+)');
      final match = regex.firstMatch(errorStr);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    if (errorStr.startsWith('Exception: ')) {
      return errorStr.replaceFirst('Exception: ', '');
    }

    return errorStr;
  }

  Future<void> _refresh() async {
    _page = 1;
    await ref
        .read(leaveApprovalProvider.notifier)
        .loadAppliedLeaves(
          page: _page,
          limit: _limit,
          designationId: _selectedDesignationId,
          storeId: _selectedStoreId,
        );
  }

  void _onFilterChanged() {
    _page = 1;
    ref
        .read(leaveApprovalProvider.notifier)
        .loadAppliedLeaves(
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
            title: "Designation",
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
            title: "Store",
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
    final hasActiveFilters =
        _selectedDesignationId != null || _selectedStoreId != null;

    return AppSurface(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveApprovalProvider);

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(child: Text(_extractErrorMessage(e))),
                ),
              ),
            ),
            data: (data) {
              if (data == null || data.records.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(child: Text("No applied leaves")),
                    ),
                  ),
                );
              }

              final items = data.records;

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = items[i];

                    return AppSurface(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.employeeName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          if (item.store != null)
                            Text(
                              "STORE: ${item.store}",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                          if (item.empCode != null)
                            Text(
                              "EmpCode: ${item.empCode}",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                          if (item.designation != null)
                            Text(
                              "Designation:${item.designation}",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            "${item.fromDate} → ${item.toDate}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Text("Type: ${item.leaveType}"),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _showRejectSheet(item),
                                  child: const Text("Reject"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () =>
                                      _showPartialApprovalSheet(item),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedValue ?? "All",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
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
  State<_SearchableListSheet<T>> createState() =>
      _SearchableListSheetState<T>();
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
            .where(
              (item) => widget.getItemName(item).toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppVisuals.of(context);
    return FilterSheetScaffold(
      title: widget.title,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search_rounded, color: colors.muted),
                filled: true,
                fillColor: colors.inset,
                hintStyle: TextStyle(color: colors.muted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              title: Text(
                'All ${widget.title}s',
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.normal,
                ),
              ),
              trailing: widget.selectedId == null
                  ? Icon(Icons.check_rounded, color: colors.accent)
                  : null,
              onTap: () => Navigator.pop(context, {'id': null, 'name': null}),
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: colors.border),
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'No results found',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final itemId = widget.getItemId(item);
                      final itemName = widget.getItemName(item);
                      final isSelected = itemId == widget.selectedId;

                      return ListTile(
                        selected: isSelected,
                        selectedColor: colors.accent,
                        selectedTileColor: colors.accentSurface,
                        title: Text(
                          itemName,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded, color: colors.accent)
                            : null,
                        onTap: () {
                          Navigator.pop(context, {
                            'id': itemId,
                            'name': itemName,
                          });
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
