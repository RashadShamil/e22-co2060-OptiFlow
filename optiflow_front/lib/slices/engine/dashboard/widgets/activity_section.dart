import 'package:flutter/material.dart';
import 'package:optiflow_scheduler/core/utils/app_colors.dart';
import 'package:optiflow_scheduler/core/services/supabase_service.dart';

class LiveAlerts extends StatefulWidget {
  const LiveAlerts({super.key});

  @override
  State<LiveAlerts> createState() => _LiveAlertsState();
}

class _LiveAlertsState extends State<LiveAlerts> {
  bool _isLoading = true;
  List<dynamic> _offlineMachines = [];
  List<dynamic> _overdueJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    final stats = await SupabaseService.instance.fetchDashboardStats();
    if (mounted) {
      setState(() {
        _offlineMachines = (stats['offline_machines'] as List?) ?? [];
        _overdueJobs = (stats['overdue_jobs'] as List?) ?? [];
        _isLoading = false;
      });
    }
  }

  int get _alertCount => _offlineMachines.length + _overdueJobs.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Live Alerts",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isLoading ? '...' : '$_alertCount',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
          else if (_alertCount == 0)
            _buildAlertItem(Icons.check_circle_outline, "All Clear", "No alerts at this time.", AppColors.success)
          else ...[
            if (_offlineMachines.isNotEmpty)
              _buildAlertItem(
                Icons.warning_amber_rounded,
                "${_offlineMachines.length} Machine${_offlineMachines.length > 1 ? 's' : ''} Offline/Idle",
                _offlineMachines.map((m) => m['name'] as String).join(', '),
                AppColors.error,
              ),
            if (_offlineMachines.isNotEmpty && _overdueJobs.isNotEmpty)
              const SizedBox(height: 12),
            if (_overdueJobs.isNotEmpty)
              _buildAlertItem(
                Icons.schedule,
                "${_overdueJobs.length} Overdue Job${_overdueJobs.length > 1 ? 's' : ''}",
                _overdueJobs.map((j) => j['title'] as String).join(', '),
                AppColors.warning,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  bool _isLoading = true;
  List<dynamic> _recentTasks = [];
  List<dynamic> _newJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchActivity();
  }

  Future<void> _fetchActivity() async {
    final stats = await SupabaseService.instance.fetchDashboardStats();
    if (mounted) {
      setState(() {
        _recentTasks = (stats['recent_tasks'] as List?) ?? [];
        _newJobs = (stats['new_jobs'] as List?) ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              ),
            )
          else if (_recentTasks.isEmpty && _newJobs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  "No recent activity found.",
                  style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontStyle: FontStyle.italic),
                ),
              ),
            )
          else ...[
            // Completed tasks
            ..._recentTasks.map((task) {
              final jobTitle = task['jobs']?['title'] as String? ?? 'Unknown Job';
              final resourceName = task['resources']?['name'] as String? ?? 'Unknown Resource';
              return _buildActivityItem(
                color: AppColors.success,
                title: "Task completed: ${task['name'] ?? 'Task'}",
                subtitle: "$jobTitle — $resourceName",
                time: _timeAgo(task['completed_at']),
              );
            }),
            // New jobs created
            ..._newJobs.map((job) {
              return _buildActivityItem(
                color: AppColors.info,
                title: "New job created: ${job['title'] ?? 'Job'}",
                subtitle: "Status: ${job['status'] ?? 'DRAFT'}",
                time: _timeAgo(job['created_at']),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _timeAgo(String? isoString) {
    if (isoString == null) return 'Unknown';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      return "${diff.inDays}d ago";
    } catch (_) {
      return 'Unknown';
    }
  }

  Widget _buildActivityItem({
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
