import 'dart:async';

import 'package:dazzleshrms/core/app_theme/app_page_bar.dart';
import 'package:dazzleshrms/core/app_theme/app_surface.dart';
import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:dazzleshrms/core/app_theme/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/app_theme/app_theme.dart';
import '../../announcements/data/models/store_model.dart';
import '../../approvals/data/models/designation_model.dart';
import '../../approvals/data/providers/approvals_provider.dart';
import '../data/models/break_dashboard_employee_response.dart';
import '../data/providers/break_report_provider.dart';
import 'widgets/employee_avatar.dart';
import 'widgets/break_report_date_range_picker.dart';
import 'widgets/searchable_filter_sheet.dart';
import 'employee_break_summary_screen.dart';

const double _filterControlHeight = 46;

class EmployeeDashboardscreen extends ConsumerStatefulWidget {
  const EmployeeDashboardscreen({super.key});

  @override
  ConsumerState<EmployeeDashboardscreen> createState() =>
      _BreakReportsDashboardscreenState();
}

class _BreakReportsDashboardscreenState
    extends ConsumerState<EmployeeDashboardscreen> {
  static const int _limit = 10;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _employeeSearchController =
      TextEditingController();

  int? _selectedStoreId;
  int? _selectedDesignationId;
  String? _selectedStoreName;
  String? _selectedDesignationName;
  DateTimeRange? _selectedRange;
  final _displayDateFormat = DateFormat('dd MMM yyyy');

  int _currentPage = 1;
  bool _isLoadingMore = false;
  String? _submittedSearch;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storeProvider);
      ref.read(designationProvider);
      _loadEmployees();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _employeeSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees({bool append = false}) async {
    await ref
        .read(breakDashboardEmployeesProvider.notifier)
        .fetchEmployees(
          storeId: _selectedStoreId,
          designationId: _selectedDesignationId,
          page: _currentPage,
          limit: _limit,
          append: append,
          search: _submittedSearch,
        );
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _checkIfNeedMoreData(),
      );
    }
  }

  void _checkIfNeedMoreData() {
    if (!mounted || !_scrollController.hasClients || _isLoadingMore) return;
    if (_scrollController.position.maxScrollExtent <= 100) {
      final data = ref.read(breakDashboardEmployeesProvider).valueOrNull;
      if (data == null) return;
      final hasMorePages = data.totalPages > 0
          ? _currentPage < data.totalPages
          : (data.totalItems > 0
                ? data.data.length < data.totalItems
                : data.data.length >= _currentPage * _limit);
      if (hasMorePages) {
        _loadNextPage();
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll < maxScroll - 150) {
      return;
    }
    final data = ref.read(breakDashboardEmployeesProvider).valueOrNull;
    if (data == null) return;

    final hasMorePages = data.totalPages > 0
        ? _currentPage < data.totalPages
        : (data.totalItems > 0
              ? data.data.length < data.totalItems
              : data.data.length >= _currentPage * _limit);

    if (!hasMorePages) return;
    _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;
    await ref
        .read(breakDashboardEmployeesProvider.notifier)
        .fetchEmployees(
          storeId: _selectedStoreId,
          designationId: _selectedDesignationId,
          page: nextPage,
          limit: _limit,
          append: true,
          search: _submittedSearch,
        );
    if (mounted) {
      setState(() {
        _currentPage = nextPage;
        _isLoadingMore = false;
      });
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _checkIfNeedMoreData(),
      );
    }
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    final search = _employeeSearchController.text.trim();
    setState(() {
      _selectedStoreId = null;
      _selectedDesignationId = null;
      _selectedStoreName = null;
      _selectedDesignationName = null;
      _selectedRange = null;
      _currentPage = 1;
      _isLoadingMore = false;
      _submittedSearch = search.isEmpty ? null : search;
    });
    _loadEmployees();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showBreakReportDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange:
          _selectedRange ??
          DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedRange = picked);
  }

  void _onEmployeeFiltersChanged() {
    _searchDebounce?.cancel();
    final search = _employeeSearchController.text.trim();
    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
      _submittedSearch = search.isEmpty ? null : search;
    });
    _loadEmployees();
  }

  void _onEmployeeSearchChanged(String value) {
    _searchDebounce?.cancel();
    setState(() {});
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      _applyEmployeeSearch(value);
    });
  }

  void _applyEmployeeSearch(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
      _submittedSearch = query.isEmpty ? null : query;
    });
    _loadEmployees();
  }

  void _clearEmployeeSearch() {
    _employeeSearchController.clear();
    _applyEmployeeSearch('');
  }

  void _showStorePicker() async {
    final result = await showSearchableFilterSheet<Store>(
      context: context,
      provider: storeProvider,
      title: 'Store',
      selectedId: _selectedStoreId,
      getItemId: (item) => item.storeId,
      getItemName: (item) => item.storeName,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedStoreId = result['id'];
        _selectedStoreName = result['name'];
      });
      _onEmployeeFiltersChanged();
    }
  }

  void _showDesignationPicker() async {
    final result = await showSearchableFilterSheet<Designation>(
      context: context,
      provider: designationProvider,
      title: 'Designation',
      selectedId: _selectedDesignationId,
      getItemId: (item) => item.designationId,
      getItemName: (item) => item.designation,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedDesignationId = result['id'];
        _selectedDesignationName = result['name'];
      });
      _onEmployeeFiltersChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = AppVisuals.of(context);
    final hasFilters =
        _selectedStoreId != null ||
        _selectedDesignationId != null ||
        _selectedRange != null;
    ref.watch(storeProvider);
    ref.watch(designationProvider);

    return AppScaffold(
      appBar: AppPageBar(
        title: 'Employee Dashboard',
        actions: [
          IconButton(
            onPressed: _pickDateRange,
            tooltip: _selectedRange == null
                ? 'Filter by date range'
                : '${_displayDateFormat.format(_selectedRange!.start)} – ${_displayDateFormat.format(_selectedRange!.end)}',
            icon: Icon(
              Icons.calendar_month_outlined,
              color: _selectedRange == null
                  ? null
                  : AppVisuals.of(context).accent,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              height: _filterControlHeight,
              child: TextField(
                key: const Key('break-dashboard-employee-search'),
                controller: _employeeSearchController,
                textInputAction: TextInputAction.search,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
                onChanged: _onEmployeeSearchChanged,
                onSubmitted: _applyEmployeeSearch,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: colors.inset,
                  hintText: 'Search employees ',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.muted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: colors.accent,
                  ),
                  suffixIcon: _employeeSearchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: _clearEmployeeSearch,
                          icon: const Icon(Icons.close_rounded, size: 19),
                        ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: _filterControlHeight,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.dark
                          ? colors.border.withValues(alpha: .65)
                          : colors.muted.withValues(alpha: .25),
                      width: colors.dark ? 1 : .5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.dark
                          ? colors.border.withValues(alpha: .65)
                          : colors.muted.withValues(alpha: .25),
                      width: colors.dark ? 1 : .5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.accent),
                  ),
                ),
              ),
            ),
          ),

          // ── Filter Row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _FilterChip(
                    label: 'Store',
                    selectedValue: _selectedStoreName,
                    onTap: _showStorePicker,
                    onClear: _selectedStoreId != null
                        ? () {
                            setState(() {
                              _selectedStoreId = null;
                              _selectedStoreName = null;
                            });
                            _onEmployeeFiltersChanged();
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    label: 'Designation',
                    selectedValue: _selectedDesignationName,
                    onTap: _showDesignationPicker,
                    onClear: _selectedDesignationId != null
                        ? () {
                            setState(() {
                              _selectedDesignationId = null;
                              _selectedDesignationName = null;
                            });
                            _onEmployeeFiltersChanged();
                          }
                        : null,
                  ),
                ),
                if (hasFilters) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    tooltip: 'Clear filters',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(child: _buildEmployeeContent(isDark)),
        ],
      ),
    );
  }

  // ── Employee list / loading / error ─────────────────────────────────────
  Widget _buildEmployeeContent(bool isDark) {
    final state = ref.watch(breakDashboardEmployeesProvider);
    return state.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: AppVisuals.of(context).accent),
      ),
      error: (err, _) => _buildErrorWidget(isDark, err.toString()),
      data: (data) {
        if (data == null || data.data.isEmpty) {
          return _buildEmptyWidget(isDark);
        }
        return _buildEmployeesList(isDark, data);
      },
    );
  }

  Widget _buildEmployeesList(bool isDark, BreakDashboardEmployeeData data) {
    final extra = _isLoadingMore ? 1 : 0;

    return RefreshIndicator(
      color: AppVisuals.of(context).accent,
      onRefresh: () async {
        setState(() {
          _currentPage = 1;
          _isLoadingMore = false;
        });
        await _loadEmployees();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${data.totalItems} employee${data.totalItems == 1 ? '' : 's'} found',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark
                        ? AppTheme.textMutedDark
                        : AppTheme.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: data.data.length + extra,
              separatorBuilder: (context, index) {
                if (index >= data.data.length - 1) {
                  return const SizedBox.shrink();
                }
                return Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                );
              },
              itemBuilder: (context, index) {
                if (index >= data.data.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                return _buildEmployeeRow(isDark, data.data[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(bool isDark, BreakDashboardEmployeeItem emp) {
    void openSummary() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmployeeBreakSummaryScreen(
            employee: emp,
            initialDateRange: _selectedRange,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          EmployeeAvatar(
            name: emp.employeeName,
            profileImage: emp.profileImage,
            enablePreview: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: openSummary,
              borderRadius: BorderRadius.circular(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emp.employeeName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emp.employeeCode,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppTheme.textMutedDark
                          : AppTheme.textMutedLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark, String message) {
    return RefreshIndicator(
      color: AppVisuals.of(context).accent,
      onRefresh: () async {
        setState(() {
          _currentPage = 1;
          _isLoadingMore = false;
        });
        await _loadEmployees();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppTheme.statusError,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load employees',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark
                          ? AppTheme.textMutedDark
                          : AppTheme.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentPage = 1;
                        _isLoadingMore = false;
                      });
                      _loadEmployees();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppVisuals.of(context).accent,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(bool isDark) {
    return RefreshIndicator(
      color: AppVisuals.of(context).accent,
      onRefresh: () async {
        setState(() {
          _currentPage = 1;
          _isLoadingMore = false;
        });
        await _loadEmployees();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 52,
                    color: isDark
                        ? AppTheme.textMutedDark
                        : AppTheme.textMutedLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Employees Found',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No employees match your search or filters.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark
                          ? AppTheme.textMutedDark
                          : AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable filter chip widget (same as break_reports_screen) ─────────────

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
    final colors = AppVisuals.of(context);
    return SizedBox(
      height: _filterControlHeight,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: colors.inset,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.dark
                  ? colors.border.withValues(alpha: .65)
                  : colors.muted.withValues(alpha: .25),
              width: colors.dark ? 1 : .5,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedValue ?? label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isSelected && onClear != null)
                    GestureDetector(
                      onTap: onClear,
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 20,
                        color: colors.accent,
                      ),
                    )
                  else
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: colors.accent,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable searchable bottom sheet (same as break_reports_screen) ────────

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
  late List<T> _filteredItems;

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
      _filteredItems = query.isEmpty
          ? widget.items
          : widget.items
                .where(
                  (item) =>
                      widget.getItemName(item).toLowerCase().contains(query),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      height: MediaQuery.of(context).size.height * 0.75,
      sheet: true,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select ${widget.title}',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
          ListTile(
            leading: Radio<int?>(
              value: null,
              groupValue: widget.selectedId,
              onChanged: (_) {
                Navigator.pop(context, {'id': null, 'name': null});
              },
            ),
            title: Text('All ${widget.title}s'),
            onTap: () => Navigator.pop(context, {'id': null, 'name': null}),
          ),
          const Divider(height: 1),
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
                          onChanged: (_) => Navigator.pop(context, {
                            'id': itemId,
                            'name': itemName,
                          }),
                        ),
                        title: Text(
                          itemName,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, {
                          'id': itemId,
                          'name': itemName,
                        }),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
