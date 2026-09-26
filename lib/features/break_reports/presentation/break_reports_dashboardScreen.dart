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
import 'widgets/employee_avatar.dart';
import 'widgets/searchable_filter_sheet.dart';
import 'employee_break_summary_screen.dart';

class BreakReportsDashboardscreen extends ConsumerStatefulWidget {
  const BreakReportsDashboardscreen({super.key});

  @override
  ConsumerState<BreakReportsDashboardscreen> createState() =>
      _BreakReportsDashboardscreenState();
}

class _BreakReportsDashboardscreenState
    extends ConsumerState<BreakReportsDashboardscreen> {
  final ScrollController _scrollController = ScrollController();

  int? _selectedStoreId;
  int? _selectedDesignationId;
  String? _selectedStoreName;
  String? _selectedDesignationName;
  DateTimeRange? _selectedRange;
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _displayDateFormat = DateFormat('dd MMM yyyy');

  String? get _fromDate =>
      _selectedRange == null ? null : _dateFormat.format(_selectedRange!.start);
  String? get _toDate =>
      _selectedRange == null ? null : _dateFormat.format(_selectedRange!.end);

  int _currentPage = 1;
  bool _isLoadingMore = false;

  int get _limit {
    try {
      final size = MediaQuery.of(context).size;
      return (size.shortestSide >= 600 || size.height >= 900) ? 25 : 15;
    } catch (_) {
      return 20;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storeProvider);
      ref.read(designationProvider);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees({bool append = false}) async {
    if (_selectedStoreId == null || _selectedDesignationId == null) return;
    await ref.read(breakDashboardEmployeesProvider.notifier).fetchEmployees(
          storeId: _selectedStoreId!,
          designationId: _selectedDesignationId!,
          page: _currentPage,
          limit: _limit,
          append: append,
          fromDate: _fromDate,
          toDate: _toDate,
        );
    if (mounted) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _checkIfNeedMoreData());
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
    await ref.read(breakDashboardEmployeesProvider.notifier).fetchEmployees(
          storeId: _selectedStoreId!,
          designationId: _selectedDesignationId!,
          page: nextPage,
          limit: _limit,
          append: true,
          fromDate: _fromDate,
          toDate: _toDate,
        );
    if (mounted) {
      setState(() {
        _currentPage = nextPage;
        _isLoadingMore = false;
      });
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _checkIfNeedMoreData());
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStoreId = null;
      _selectedDesignationId = null;
      _selectedStoreName = null;
      _selectedDesignationName = null;
      _selectedRange = null;
      _currentPage = 1;
      _isLoadingMore = false;
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: _selectedRange ??
          DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.PrimaryColor,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedRange = picked);
    _onFilterChanged();
  }

  void _onFilterChanged() {
    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
    });
    _loadEmployees();
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
      _onFilterChanged();
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
      _onFilterChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasFilters =
        _selectedStoreId != null || _selectedDesignationId != null ||
        _selectedRange != null;
    final bothSelected =
        _selectedStoreId != null && _selectedDesignationId != null;
    ref.watch(storeProvider);
    ref.watch(designationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Break Dashboard'),
        centerTitle: true,
        elevation: 0,
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
                  : AppTheme.PrimaryColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                            _onFilterChanged();
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
                            _onFilterChanged();
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
          Expanded(
            child: !bothSelected
                ? _buildGuideText(isDark)
                : _buildEmployeeContent(isDark),
          ),
        ],
      ),
    );
  }

  // ── Guide text shown when store or designation is not yet selected ──────
  Widget _buildGuideText(bool isDark) {
    final storeSelected = _selectedStoreId != null;
    final designationSelected = _selectedDesignationId != null;

    String message;
    if (!storeSelected && !designationSelected) {
      message = 'Select a Store and Designation\nto view employees';
    } else if (!storeSelected) {
      message = 'Select a Store to continue';
    } else {
      message = 'Select a Designation to continue';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accent(isDark).withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_list_rounded,
                size: 40,
                color: AppTheme.accent(isDark),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color:
                    isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            // Text(
            //   'Use the filters above to get started',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 12.5,
            //     color: (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight)
            //         .withValues(alpha: 0.6),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ── Employee list / loading / error ─────────────────────────────────────
  Widget _buildEmployeeContent(bool isDark) {
    final state = ref.watch(breakDashboardEmployeesProvider);
    return state.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: AppTheme.PrimaryColor),
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
      color: AppTheme.PrimaryColor,
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
      color: AppTheme.PrimaryColor,
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
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: AppTheme.statusError),
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
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
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
                      backgroundColor: AppTheme.PrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
      color: AppTheme.PrimaryColor,
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
                  Icon(Icons.people_outline_rounded,
                      size: 52,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
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
                    'No employees match the selected filters.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.accent(isDark);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: isDark ? 0.12 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: isDark ? 0.5 : 0.45)
                : Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedValue ?? label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? accent
                      : Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            if (isSelected && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.cancel_rounded, size: 18, color: accent),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
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
              .where((item) =>
                  widget.getItemName(item).toLowerCase().contains(query))
              .toList();
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
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2),
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
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
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
                    horizontal: 16, vertical: 12),
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
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
