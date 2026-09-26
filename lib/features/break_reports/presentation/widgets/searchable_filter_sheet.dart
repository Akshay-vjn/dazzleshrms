import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme/app_theme.dart';

Future<Map<String, dynamic>?> showSearchableFilterSheet<T>({
  required BuildContext context,
  required FutureProvider<List<T>> provider,
  required String title,
  required int? selectedId,
  required int Function(T) getItemId,
  required String Function(T) getItemName,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AsyncSearchableFilterSheet<T>(
      provider: provider,
      title: title,
      selectedId: selectedId,
      getItemId: getItemId,
      getItemName: getItemName,
    ),
  );
}

class AsyncSearchableFilterSheet<T> extends ConsumerWidget {
  final FutureProvider<List<T>> provider;
  final String title;
  final int? selectedId;
  final int Function(T) getItemId;
  final String Function(T) getItemName;

  const AsyncSearchableFilterSheet({
    super.key,
    required this.provider,
    required this.title,
    required this.selectedId,
    required this.getItemId,
    required this.getItemName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(provider);
    return async.when(
      data: (items) => SearchableFilterSheet<T>(
        title: title,
        items: items,
        selectedId: selectedId,
        getItemId: getItemId,
        getItemName: getItemName,
      ),
      loading: () => FilterSheetScaffold(
        title: title,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.PrimaryColor),
        ),
      ),
      error: (err, _) => FilterSheetScaffold(
        title: title,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Failed to load $title',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(provider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FilterSheetScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const FilterSheetScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
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
                    'Select $title',
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
          Expanded(child: child),
        ],
        ),
      ),
    );
  }
}

class SearchableFilterSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final int? selectedId;
  final int Function(T) getItemId;
  final String Function(T) getItemName;

  const SearchableFilterSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selectedId,
    required this.getItemId,
    required this.getItemName,
  });

  @override
  State<SearchableFilterSheet<T>> createState() =>
      _SearchableFilterSheetState<T>();
}

class _SearchableFilterSheetState<T> extends State<SearchableFilterSheet<T>> {
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
            title: Text('All ${widget.title}s'),
            trailing: widget.selectedId == null
                ? Icon(
                    Icons.check_rounded,
                    color: AppTheme.accent(
                      Theme.of(context).brightness == Brightness.dark,
                    ),
                  )
                : null,
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
                        title: Text(
                          itemName,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: AppTheme.accent(
                                  Theme.of(context).brightness ==
                                      Brightness.dark,
                                ),
                              )
                            : null,
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
