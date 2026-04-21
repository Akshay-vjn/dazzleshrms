import 'package:dio/dio.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/features/permissions_in_and_out/data/models/attendance_permission_pending_model.dart';
import 'package:dazzleshrms/features/permissions_in_and_out/data/providers/attendance_permission_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repo/attendance_permission_repo.dart';

class PermissionApprovalsScreen extends ConsumerStatefulWidget {
  const PermissionApprovalsScreen({super.key});

  @override
  ConsumerState<PermissionApprovalsScreen> createState() =>
      _PermissionApprovalsScreenState();
}

class _PermissionApprovalsScreenState
    extends ConsumerState<PermissionApprovalsScreen>
    with SingleTickerProviderStateMixin {
  int? _processingId;
  late final TabController _tabController;

  PermissionApprovalType get _selectedType =>
      _tabController.index == 0
          ? PermissionApprovalType.inOut
          : PermissionApprovalType.lateEarly;

  String get _emptyText => _selectedType == PermissionApprovalType.inOut
      ? 'No pending in/out permissions'
      : 'No pending late/early permissions';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _processingId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(attendancePermissionPendingProvider(_selectedType));
    await ref.read(attendancePermissionPendingProvider(_selectedType).future);
  }

  String _timeRange(AttendancePermissionPendingItem item) {
    final from = item.fromTimeFormatted ?? item.fromTime ?? '--';
    final to = item.toTimeFormatted ?? item.toTime ?? '--';
    return '$from - $to';
  }

  Future<void> _runAction({
    required AttendancePermissionPendingItem item,
    required bool approve,
  }) async {
    if (_processingId != null) return;

    setState(() {
      _processingId = item.permissionId;
    });

    try {
      final repo = ref.read(attendancePermissionRepositoryProvider);
      final message = approve
          ? await repo.approve(
              permissionId: item.permissionId,
              approvalType: _selectedType,
            )
          : await repo.reject(
              permissionId: item.permissionId,
              approvalType: _selectedType,
            );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.statusSuccess,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      await _refresh(ref);
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data?['message']?.toString() ??
          'Failed to update attendance permission';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.statusError,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.statusError,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingState = ref.watch(attendancePermissionPendingProvider(_selectedType));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Approvals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'In / Out'),
            Tab(text: 'Late / Early'),
          ],
        ),
      ),
      body: pendingState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            ),
          ),
        ),
        data: (data) {
          if (data.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Text(_emptyText),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: data.items.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = data.items[index];
                final isProcessing = _processingId == item.permissionId;
                final statusColor = item.status.toUpperCase() == 'PENDING'
                    ? AppTheme.statusWarning
                    : AppTheme.statusInfo;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.employeeName ?? 'Employee #${item.employeeId}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (_selectedType == PermissionApprovalType.lateEarly)
                        Text(
                          item.typeLabel,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      else
                        Text(
                          'In / Out',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      const SizedBox(height: 6),
                      if ((item.storeName ?? '').isNotEmpty)
                        Text(
                          'Store: ${item.storeName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      Text(
                        'Date: ${item.date}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Time: ${_timeRange(item)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Duration: ${item.durationText ?? '${item.totalMinutes} mins'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reason: ${item.reason}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isProcessing
                                  ? null
                                  : () => _runAction(item: item, approve: false),
                              child: isProcessing
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: isProcessing
                                  ? null
                                  : () => _runAction(item: item, approve: true),
                              child: isProcessing
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Approve'),
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
    );
  }
}
