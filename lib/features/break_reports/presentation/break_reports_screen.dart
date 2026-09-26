import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api_constants/api_constants.dart';
import '../../../core/app_theme/app_theme.dart';
import '../../../core/storage/session_storage.dart';
import '../../announcements/data/models/employee_model.dart';
import '../../dashboard/data/providers/dashboard_provider.dart';
import '../../announcements/data/models/store_model.dart';
import '../../announcements/data/providers/announcement_provider.dart';
import '../../approvals/data/models/designation_model.dart';
import '../../approvals/data/providers/approvals_provider.dart';
import '../data/models/break_report_response.dart';
import '../data/providers/break_report_provider.dart';
import 'break_reports_dashboardScreen.dart';
import 'widgets/searchable_filter_sheet.dart';

class BreakReportsScreen extends ConsumerStatefulWidget {
  const BreakReportsScreen({super.key});

  @override
  ConsumerState<BreakReportsScreen> createState() =>
      _BreakReportsDashboardScreenState();
}

class _BreakReportsDashboardScreenState
    extends ConsumerState<BreakReportsScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<BreakReportItem> _items = [];

  DateTime _selectedDate = DateTime.now();
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

  int? _selectedStoreId;
  int? _selectedDesignationId;
  int? _selectedEmployeeId;
  String? _selectedStoreName;
  String? _selectedDesignationName;
  String? _selectedEmployeeName;
  String _sessionRole = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _sessionRole = (await SessionStorage.getRole()) ?? '';
      final employeeId = await SessionStorage.getEmployeeId();
      final savedStoreId = employeeId == null
          ? null
          : await SessionStorage.getBreakReportsStoreFilter(employeeId);
      final savedStoreName = employeeId == null
          ? null
          : await SessionStorage.getBreakReportsStoreFilterName(employeeId);
      if (!mounted) return;
      setState(() {
        _selectedStoreId = savedStoreId;
        _selectedStoreName = savedStoreName;
      });
      ref.read(storeProvider);
      ref.read(designationProvider);
      _loadData();
    });
  }

  Future<void> _saveStoreFilter({int? storeId, String? storeName}) async {
    final employeeId = await SessionStorage.getEmployeeId();
    if (employeeId == null) return;
    await SessionStorage.saveBreakReportsStoreFilter(
      employeeId: employeeId,
      storeId: storeId,
      storeName: storeName,
    );
  }

  bool _showStoreDesignationFilters(String? dashboardRole) {
    final role = ((dashboardRole != null && dashboardRole.isNotEmpty)
        ? dashboardRole
        : _sessionRole)
        .toLowerCase()
        .trim();
    return role == 'master admin' || role == 'hr';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void _loadData() {
    _items.clear();
    _currentPage = 1;
    ref.read(breakReportProvider.notifier).loadBreakReports(
      page: _currentPage,
      limit: _limit,
      date: _formattedDate,
      storeId: _selectedStoreId,
      designationId: _selectedDesignationId,
      employeeId: _selectedEmployeeId,
      append: false,
    );
    if (mounted) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _checkIfNeedMoreData());
    }
  }

  void _checkIfNeedMoreData() {
    if (!mounted || !_scrollController.hasClients || _isLoadingMore) return;
    if (_scrollController.position.maxScrollExtent <= 100) {
      final state = ref.read(breakReportProvider);
      state.whenOrNull(
        data: (data) {
          if (data == null) return;
          final hasMorePages = data.totalPages > 0
              ? _currentPage < data.totalPages
              : (data.totalItems > 0
                  ? _items.length < data.totalItems
                  : data.records.length >= _limit);
          if (hasMorePages) {
            _loadNextPage();
          }
        },
      );
    }
  }

  void _onFilterChanged() {
    setState(() => _items.clear());
    _loadData();
  }

  void _clearFilters() {
    setState(() {
      _selectedStoreId = null;
      _selectedDesignationId = null;
      _selectedEmployeeId = null;
      _selectedStoreName = null;
      _selectedDesignationName = null;
      _selectedEmployeeName = null;
    });
    unawaited(_saveStoreFilter());
    _onFilterChanged();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll < maxScroll - 150) return;

    final state = ref.read(breakReportProvider);
    state.whenOrNull(
      data: (data) {
        if (data == null) return;
        final hasMorePages = data.totalPages > 0
            ? _currentPage < data.totalPages
            : (data.totalItems > 0
                ? _items.length < data.totalItems
                : data.records.length >= _limit);
        if (hasMorePages) {
          _loadNextPage();
        }
      },
    );
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;
    await ref.read(breakReportProvider.notifier).loadBreakReports(
      page: nextPage,
      limit: _limit,
      date: _formattedDate,
      storeId: _selectedStoreId,
      designationId: _selectedDesignationId,
      employeeId: _selectedEmployeeId,
      append: true,
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);
        final actionColor = theme.brightness == Brightness.light
            ? AppTheme.textPrimaryLight
            : AppTheme.PrimaryColor;
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppTheme.PrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: actionColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _onFilterChanged();
    }
  }

  String _getFullImageUrl(String profileImage) {
    return ApiConstants.resolveMediaUrl(profileImage);
  }

  Color _minutesColor(BreakReportItem item) {
    if (!item.hasDurationColorRule) return AppTheme.textBodyLight;
    return item.isOverLimit ? AppTheme.statusError : AppTheme.statusSuccess;
  }

  void _showStorePicker() async {
    // Fetch first and pass this exact response into the sheet so it cannot
    // render a previously cached store list.
    debugPrint('[StoreFilterSheet] Opened; requesting GET /stores');
    late final List<Store> stores;
    try {
      stores = await ref.refresh(storeProvider.future);
      debugPrint('[StoreFilterSheet] Fresh store options: $stores');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stores: $error')),
      );
      return;
    }
    if (!mounted) return;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchableFilterSheet<Store>(
        title: 'Store',
        items: stores,
        selectedId: _selectedStoreId,
        getItemId: (item) => item.storeId,
        getItemName: (item) => item.storeName,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedStoreId = result['id'];
        _selectedStoreName = result['name'];
        _selectedEmployeeId = null;
        _selectedEmployeeName = null;
      });
      await _saveStoreFilter(
        storeId: result['id'],
        storeName: result['name'],
      );
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
        _selectedEmployeeId = null;
        _selectedEmployeeName = null;
      });
      _onFilterChanged();
    }
  }

  void _showEmployeePicker() async {
    final key = '${_selectedStoreId ?? ''}|${_selectedDesignationId ?? ''}';
    final employeesAsync =
    ref.read(employeesByStoreAndDesignationProvider(key));
    await employeesAsync.when(
      data: (employees) async {
        final result = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _SearchableListSheet<Employee>(
            title: 'Employee',
            items: employees,
            selectedId: _selectedEmployeeId,
            getItemId: (item) => item.employeeId,
            getItemName: (item) => item.employeeName,
          ),
        );
        if (result != null && mounted) {
          setState(() {
            _selectedEmployeeId = result['id'];
            _selectedEmployeeName = result['name'];
          });
          _onFilterChanged();
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }



  Widget _buildDateFilter(bool isDark) {
    final isToday =
        DateFormat('yyyy-MM-dd').format(DateTime.now()) == _formattedDate;
    final accent = AppTheme.accent(isDark);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.12 : 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: accent.withValues(alpha: isDark ? 0.3 : 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 15, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    isToday
                        ? 'Today'
                        : DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BreakReportsDashboardscreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.12 : 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: accent.withValues(alpha: isDark ? 0.3 : 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.dashboard_rounded,
                    size: 16,
                    color: accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: accent,
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

  Widget _buildFilters() {
    final hasActiveFilters = _selectedStoreId != null ||
        _selectedDesignationId != null ||
        _selectedEmployeeId != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                  _selectedEmployeeId = null;
                  _selectedEmployeeName = null;
                });
                unawaited(_saveStoreFilter());
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
                  _selectedEmployeeId = null;
                  _selectedEmployeeName = null;
                });
                _onFilterChanged();
              }
                  : null,
            ),
          ),
          if (hasActiveFilters) ...[
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
    );
  }

  void _showImagePopup(BreakReportItem item) {
    final imageUrl = _getFullImageUrl(item.profileImage);
    final letter =
    item.employeeName.isNotEmpty ? item.employeeName[0].toUpperCase() : '?';

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
                    child: imageUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 4.0,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color:
                              AppTheme.PrimaryColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: const TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                        : Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppTheme.PrimaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close_rounded, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(BreakReportItem item, bool isDark) {
    final imageUrl = _getFullImageUrl(item.profileImage);
    final hasImage = imageUrl.isNotEmpty;
    final letter =
    item.employeeName.isNotEmpty ? item.employeeName[0].toUpperCase() : '?';
    final accent = AppTheme.accent(isDark);

    final avatarWidget = hasImage
        ? Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: accent.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: accent.withValues(alpha: 0.12),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            placeholder: (_, __) => Text(
              letter,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            errorWidget: (_, __, ___) => Text(
              letter,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    )
        : CircleAvatar(
      radius: 24,
      backgroundColor: accent.withValues(alpha: 0.12),
      child: Text(
        letter,
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );

    return GestureDetector(
      onTap: () => _showImagePopup(item),
      child: avatarWidget,
    );
  }

  Widget _buildRow(BreakReportItem item, bool isDark) {
    final accent = item.hasDurationColorRule
        ? (item.isOverLimit ? AppTheme.statusError : AppTheme.statusSuccess)
        : (isDark ? Colors.white24 : AppTheme.textMutedLight);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _buildAvatar(item, isDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.employeeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.displayBreakName,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppTheme.textMutedLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.displayDuration,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _minutesColor(item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final breakReportState = ref.watch(breakReportProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dashboardRole = ref.watch(dashboardProvider).valueOrNull?.role;
    final showStoreDesignationFilters =
    _showStoreDesignationFilters(dashboardRole);
    if (showStoreDesignationFilters) {
      ref.watch(storeProvider);
      ref.watch(designationProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Break Reports'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildDateFilter(isDark),
          if (showStoreDesignationFilters) _buildFilters(),
          const SizedBox(height: 4),
          Expanded(
            child: breakReportState.when(
              loading: () {
                if (_items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildList(isDark, isLoadingMore: true);
              },
              error: (e, _) => RefreshIndicator(
                onRefresh: () async => _loadData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(e.toString()),
                      ),
                    ),
                  ),
                ),
              ),
              data: (data) {
                if (data != null) {
                  for (final item in data.records) {
                    if (!_items
                        .any((e) => e.employeeBreakId == item.employeeBreakId)) {
                      _items.add(item);
                    }
                  }
                  assignBreakIndices(_items);
                }

                if (_items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Text(
                            'No break records found',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white54
                                  : AppTheme.textMutedLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return _buildList(isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isDark, {bool isLoadingMore = false}) {
    final loading = isLoadingMore || _isLoadingMore;
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _items.length + (loading ? 1 : 0),
        separatorBuilder: (_, index) => index == _items.length - 1
            ? const SizedBox.shrink()
            : Divider(
          height: 1,
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildRow(_items[index], isDark);
        },
      ),
    );
  }
}

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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }
}

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
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
                (item) => widget.getItemName(item).toLowerCase().contains(query))
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
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
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
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            onTap: () {
              Navigator.pop(context, {'id': null, 'name': null});
            },
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
                    onChanged: (_) {
                      Navigator.pop(context, {
                        'id': itemId,
                        'name': itemName,
                      });
                    },
                  ),
                  title: Text(
                    itemName,
                    style: TextStyle(
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
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
