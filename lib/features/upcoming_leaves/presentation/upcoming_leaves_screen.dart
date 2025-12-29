import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/upcoming_leave_provider.dart';
import '../data/models/upcoming_leave_model.dart';
import 'change_leave_dialog.dart';

class UpcomingLeaveScreen extends ConsumerStatefulWidget {
  const UpcomingLeaveScreen({super.key});

  @override
  ConsumerState<UpcomingLeaveScreen> createState() =>
      _UpcomingLeaveScreenState();
}

class _UpcomingLeaveScreenState
    extends ConsumerState<UpcomingLeaveScreen> {
  final ScrollController _controller = ScrollController();

  int _page = 1;
  final int _limit = 10;
  bool _isLoadingMore = false;

  final List<UpcomingLeaveItem> _items = [];

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upcomingLeaveProvider.notifier).loadUpcomingLeaves(
        page: _page,
        limit: _limit,
      );
    });
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 120 &&
        !_isLoadingMore) {
      final state = ref.read(upcomingLeaveProvider);

      state.whenOrNull(
        data: (data) {
          if (data == null) return;
          if (_page < data.totalPages) {
            _loadNext();
          }
        },
      );
    }
  }

  Future<void> _loadNext() async {
    _isLoadingMore = true;
    _page++;

    await ref.read(upcomingLeaveProvider.notifier).loadUpcomingLeaves(
      page: _page,
      limit: _limit,
    );

    _isLoadingMore = false;
  }

  Future<void> _refresh() async {
    _page = 1;
    _items.clear();

    ref.invalidate(upcomingLeaveProvider);

    await ref.read(upcomingLeaveProvider.notifier).loadUpcomingLeaves(
      page: _page,
      limit: _limit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(upcomingLeaveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Leaves'),
      ),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(e.toString()),
        ),
        data: (data) {
          if (data == null || data.records.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 300),
                  Center(child: Text('No upcoming leaves')),
                ],
              ),
            );
          }

          if (_page == 1) {
            _items.clear();
          }

          for (final item in data.records) {
            if (!_items.any((e) => e.leaveId == item.leaveId)) {
              _items.add(item);
            }
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.all(16),
              itemCount: _items.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= _items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final item = _items[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => ChangeLeaveDialog(
                        logId: item.leaveId, // 🔥 IMPORTANT
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.date,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.type,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.status,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
