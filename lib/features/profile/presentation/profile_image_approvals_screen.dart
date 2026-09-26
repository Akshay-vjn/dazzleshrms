import 'package:cached_network_image/cached_network_image.dart';
import 'package:dazzleshrms/core/api_constants/api_constants.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/features/profile/data/models/profile_image_change_request.dart';
import 'package:dazzleshrms/features/profile/data/providers/profile_image_change_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileImageApprovalsScreen extends ConsumerStatefulWidget {
  const ProfileImageApprovalsScreen({super.key});

  @override
  ConsumerState<ProfileImageApprovalsScreen> createState() =>
      _ProfileImageApprovalsScreenState();
}

class _ProfileImageApprovalsScreenState
    extends ConsumerState<ProfileImageApprovalsScreen> {
  int? _updatingRequestId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileImageChangeRequestsProvider.notifier).load();
    });
  }

  Future<void> _updateRequest(
    ProfileImageChangeRequest request, {
    required bool approve,
  }) async {
    final action = approve ? 'approve' : 'reject';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${approve ? 'Approve' : 'Reject'} Image Change'),
        content: Text(
          'Do you want to $action the profile image change request from '
          '${request.employee.name.isEmpty ? request.employeeId : request.employee.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: approve ? AppTheme.dGreen : AppTheme.statusError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _updatingRequestId = request.requestId);
    try {
      final notifier = ref.read(profileImageChangeRequestsProvider.notifier);
      final message = approve
          ? await notifier.approve(request.requestId)
          : await notifier.reject(request.requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.dGreen),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppTheme.statusError,
        ),
      );
    } finally {
      if (mounted) setState(() => _updatingRequestId = null);
    }
  }

  String _requestedAt(DateTime? dateTime) {
    if (dateTime == null) return 'Requested date unavailable';
    final local = dateTime.toLocal();
    final date =
        '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    return 'Requested $date at $time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requests = ref.watch(profileImageChangeRequestsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Image Approval')),
      body: requests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => RefreshIndicator(
          onRefresh: () =>
              ref.read(profileImageChangeRequestsProvider.notifier).load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(error.toString(), textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () =>
              ref.read(profileImageChangeRequestsProvider.notifier).load(),
          child: items.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: Text('No pending image change requests'),
                    ),
                  ),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _RequestCard(
                    request: items[index],
                    isUpdating: _updatingRequestId == items[index].requestId,
                    theme: theme,
                    onApprove: () =>
                        _updateRequest(items[index], approve: true),
                    onReject: () =>
                        _updateRequest(items[index], approve: false),
                    requestedAt: _requestedAt(items[index].requestedAt),
                  ),
                ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.isUpdating,
    required this.theme,
    required this.onApprove,
    required this.onReject,
    required this.requestedAt,
  });

  final ProfileImageChangeRequest request;
  final bool isUpdating;
  final ThemeData theme;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final String requestedAt;

  @override
  Widget build(BuildContext context) {
    final employee = request.employee;
    final imageUrl = ApiConstants.resolveMediaUrl(employee.profileImage);
    final initials = employee.name.isEmpty
        ? '?'
        : employee.name[0].toUpperCase();
    final statusColor = request.status.toUpperCase() == 'PENDING'
        ? AppTheme.statusWarning
        : AppTheme.statusInfo;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
                  employee.name.isEmpty
                      ? 'Employee #${request.employeeId}'
                      : employee.name,
                  style: theme.textTheme.titleMedium?.copyWith(
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
                  request.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.PrimaryColor.withValues(alpha: 0.15),
                backgroundImage: imageUrl.isEmpty
                    ? null
                    : CachedNetworkImageProvider(imageUrl),
                child: imageUrl.isEmpty
                    ? Text(
                        initials,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Profile Image Change',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (employee.code.isNotEmpty)
            Text('EmpCode: ${employee.code}', style: theme.textTheme.bodySmall),
          if (employee.mobile.isNotEmpty)
            Text(
              'Mobile: ${employee.mobile}',
              style: theme.textTheme.bodySmall,
            ),
          Text(requestedAt, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          if (isUpdating)
            const Center(
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
