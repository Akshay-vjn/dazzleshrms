import 'package:dio/dio.dart';
import 'package:dazzleshrms/core/api_config/api_config.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class PermissionDashboard extends StatefulWidget {
  final Widget actions;

  const PermissionDashboard({
    super.key,
    required this.actions,
  });

  @override
  State<PermissionDashboard> createState() => _PermissionDashboardState();
}

class _PermissionDashboardState extends State<PermissionDashboard> {
  final Dio _dio = ApiConfig.dio;
  late Future<_PermissionDashboardData> _dashboardFuture;
  int _historyTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PermissionDashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return RefreshIndicator(
            onRefresh: _reloadDashboard,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return RefreshIndicator(
            onRefresh: _reloadDashboard,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 400,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data ?? const _PermissionDashboardData.empty();
        return RefreshIndicator(
          onRefresh: _reloadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.nextPermission != null) ...[
                  _NextPermissionCard(nextPermission: data.nextPermission!),
                  const SizedBox(height: 16),
                ],
                widget.actions,
                const SizedBox(height: 20),
                Text(
                  "History",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _HistoryTabChip(
                        label: "Late / Early",
                        selected: _historyTabIndex == 0,
                        onTap: () => setState(() => _historyTabIndex = 0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HistoryTabChip(
                        label: "In / Out",
                        selected: _historyTabIndex == 1,
                        onTap: () => setState(() => _historyTabIndex = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_selectedHistory(data).isEmpty)
                  const Text("No permission history")
                else
                  ..._selectedHistory(data).map((item) => _HistoryTile(item: item)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _reloadDashboard() async {
    setState(() {
      _dashboardFuture = _fetchDashboard();
    });
    await _dashboardFuture;
  }

  List<_HistoryItem> _selectedHistory(_PermissionDashboardData data) {
    return _historyTabIndex == 0 ? data.lateEarlyHistory : data.inOutHistory;
  }

  Future<_PermissionDashboardData> _fetchDashboard() async {
    final response = await _dio.get("/attendancepermission/dashboard");
    if (response.data == null) {
      throw Exception("No response data");
    }
    if (response.data["error"] == true) {
      throw Exception(
        (response.data["message"] ?? "Failed to fetch permission dashboard")
            .toString(),
      );
    }
    final data = response.data["data"] as Map<String, dynamic>? ?? {};
    return _PermissionDashboardData.fromJson(data);
  }
}

class _PermissionDashboardData {
  final _NextPermission? nextPermission;
  final List<_HistoryItem> lateEarlyHistory;
  final List<_HistoryItem> inOutHistory;

  const _PermissionDashboardData({
    required this.nextPermission,
    required this.lateEarlyHistory,
    required this.inOutHistory,
  });

  const _PermissionDashboardData.empty()
      : nextPermission = null,
        lateEarlyHistory = const [],
        inOutHistory = const [];

  factory _PermissionDashboardData.fromJson(Map<String, dynamic> json) {
    final nextRaw = json["nextPermission"] as Map<String, dynamic>?;
    final midPermissions = json["midPermissions"] as List<dynamic>? ?? const [];
    final attendanceAdjustments =
        json["attendanceAdjustments"] as List<dynamic>? ?? const [];
    return _PermissionDashboardData(
      nextPermission: nextRaw == null ? null : _NextPermission.fromJson(nextRaw),
      lateEarlyHistory: attendanceAdjustments
          .whereType<Map<String, dynamic>>()
          .map(_HistoryItem.fromAttendanceJson)
          .toList(),
      inOutHistory: midPermissions
          .whereType<Map<String, dynamic>>()
          .map(_HistoryItem.fromInOutJson)
          .toList(),
    );
  }
}

class _NextPermission {
  final String outTime;
  final String inTime;
  final String status;
  final String? actualOutTime;
  final String? actualInTime;

  const _NextPermission({
    required this.outTime,
    required this.inTime,
    required this.status,
    required this.actualOutTime,
    required this.actualInTime,
  });

  factory _NextPermission.fromJson(Map<String, dynamic> json) {
    return _NextPermission(
      outTime: (json["outTime"] ?? "--").toString(),
      inTime: (json["inTime"] ?? "--").toString(),
      status: (json["status"] ?? "--").toString(),
      actualOutTime: json["actualOutTime"]?.toString(),
      actualInTime: json["actualInTime"]?.toString(),
    );
  }
}

class _HistoryItem {
  final String date;
  final String? typeLabel;
  final String status;
  final String outTime;
  final String inTime;
  final String reason;

  const _HistoryItem({
    required this.date,
    required this.typeLabel,
    required this.status,
    required this.outTime,
    required this.inTime,
    required this.reason,
  });

  factory _HistoryItem.fromInOutJson(Map<String, dynamic> json) {
    return _HistoryItem(
      date: (json["date"] ?? "--").toString(),
      typeLabel: null,
      status: (json["statusText"] ?? json["status"] ?? "--").toString(),
      outTime: (json["appliedOutTimeFormatted"] ?? json["appliedOutTime"] ?? "--")
          .toString(),
      inTime:
          (json["appliedInTimeFormatted"] ?? json["appliedInTime"] ?? "--").toString(),
      reason: (json["reason"] ?? "--").toString(),
    );
  }

  factory _HistoryItem.fromAttendanceJson(Map<String, dynamic> json) {
    final type = (json["type"] ?? "").toString().toUpperCase();
    final typeLabel = type == "LATE_ENTRY" ? "Late Entry" : "Early Exit";
    return _HistoryItem(
      date: (json["date"] ?? "--").toString(),
      typeLabel: typeLabel,
      status: (json["status"] ?? "--").toString(),
      outTime: (json["fromTimeFormatted"] ?? json["fromTime"] ?? "--").toString(),
      inTime: (json["toTimeFormatted"] ?? json["toTime"] ?? "--").toString(),
      reason: (json["reason"] ?? "--").toString(),
    );
  }
}

class _NextPermissionCard extends StatelessWidget {
  final _NextPermission nextPermission;

  const _NextPermissionCard({required this.nextPermission});

  @override
  Widget build(BuildContext context) {
    final status = nextPermission.status.toUpperCase();
    final statusColor = status == "UPCOMING"
        ? AppTheme.statusInfo
        : status == "COMPLETED"
            ? AppTheme.statusSuccess
            : status == "PENDING"
                ? AppTheme.statusWarning
                : AppTheme.statusInfo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).cardColor,
            Theme.of(context).cardColor.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                "Next Permission",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TimeBlock(
                  label: "Out Time",
                  value: nextPermission.outTime,
                  icon: Icons.logout_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeBlock(
                  label: "In Time",
                  value: nextPermission.inTime,
                  icon: Icons.login_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TimeBlock({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final _HistoryItem item;

  const _HistoryTile({required this.item});

  Color _statusColor(String status) {
    final value = status.toUpperCase();
    if (value == "APPROVED" || value == "COMPLETED") {
      return AppTheme.statusSuccess;
    }
    if (value == "PENDING") {
      return AppTheme.statusWarning;
    }
    if (value == "REJECTED") {
      return AppTheme.statusError;
    }
    return AppTheme.statusInfo;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.date,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if ((item.typeLabel ?? "").isNotEmpty)
                      Text(
                        item.typeLabel!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 4),
          Text("Out: ${item.outTime}   In: ${item.inTime}"),
          Text("Reason: ${item.reason}"),
        ],
      ),
    );
  }
}

class _HistoryTabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HistoryTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? color : null,
          ),
        ),
      ),
    );
  }
}
