import 'package:flutter/material.dart';
import 'package:optiflow_scheduler/slices/engine/dashboard/widgets/activity_section.dart';
import 'package:optiflow_scheduler/core/services/supabase_service.dart';
import 'package:optiflow_scheduler/slices/engine/dashboard/widgets/op_type_chart.dart';
import 'package:optiflow_scheduler/slices/engine/dashboard/widgets/sidebar.dart';
import 'package:optiflow_scheduler/slices/engine/dashboard/widgets/stat_card.dart';
import 'package:optiflow_scheduler/slices/engine/dashboard/widgets/utilization_chart.dart';
import 'package:optiflow_scheduler/slices/admin/machines_screen.dart';
import 'package:optiflow_scheduler/slices/engine/schedule_screen.dart';
import 'package:optiflow_scheduler/slices/engine/jobs_screen.dart';
import 'package:optiflow_scheduler/core/utils/app_colors.dart';
import 'package:optiflow_scheduler/slices/admin/team_screen.dart';
import 'package:optiflow_scheduler/slices/engine/analytics_screen.dart';
import 'package:optiflow_scheduler/slices/admin/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Real stats from Supabase
  int _totalJobs       = 0;
  int _totalTasks      = 0;
  int _pendingTasks    = 0;
  double _machineUptime = 0;
  int _activeMachines  = 0;
  int _idleMachines    = 0;
  int _offlineMachines = 0;
  Map<String, int> _tasksByOpType = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final stats = await SupabaseService.instance.fetchDashboardStats();
    if (mounted) {
      setState(() {
        _totalJobs       = stats['total_jobs']        as int? ?? 0;
        _totalTasks      = stats['total_tasks']       as int? ?? 0;
        _pendingTasks    = stats['pending_tasks']     as int? ?? 0;
        _machineUptime   = (stats['uptime_pct'] as num?)?.toDouble() ?? 0.0;
        _activeMachines  = stats['active_machines']  as int? ?? 0;
        _idleMachines    = stats['idle_machines']    as int? ?? 0;
        _offlineMachines = (stats['offline_machines'] as List?)?.length ?? 0;
        _tasksByOpType   = Map<String, int>.from(stats['tasks_by_op_type'] ?? {});
        _isLoading       = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(child: _buildCurrentPage()),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0: return _buildDashboardContent();
      case 1: return const MachinesScreen();
      case 2: return const ScheduleScreen();
      case 3: return const JobsScreen();
      case 4: return const TeamScreen();
      case 5: return const AnalyticsScreen();
      case 6: return const SettingsScreen();
      default: return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildStatsRow(),
          const SizedBox(height: 32),
          _buildChartsRow(),
          const SizedBox(height: 32),
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dashboard Overview",
          style: TextStyle(
            fontSize: 36, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary, letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Welcome back to OptiFlow. Here is your shop's live performance.",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: "Total Jobs",
            value: "$_totalJobs",
            icon: Icons.inventory_2_rounded,
            iconColor: AppColors.secondary,
            percentage: 0,
            comparisonText: "in the system",
            isIncreasePositive: true,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Pending Tasks",
            value: "$_pendingTasks",
            icon: Icons.checklist_rounded,
            iconColor: AppColors.info,
            percentage: 0,
            comparisonText: "awaiting scheduling",
            isIncreasePositive: false,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Machine Uptime",
            value: "${_machineUptime.toStringAsFixed(0)}%",
            icon: Icons.precision_manufacturing_rounded,
            iconColor: AppColors.success,
            percentage: 0,
            comparisonText: "active machines",
            isIncreasePositive: true,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Total Tasks",
            value: "$_totalTasks",
            icon: Icons.account_tree_rounded,
            iconColor: AppColors.warning,
            percentage: 0,
            comparisonText: "across all jobs",
            isIncreasePositive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsRow() {
    return SizedBox(
      height: 360,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: OpTypeChart(tasksByOpType: _tasksByOpType)),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: UtilizationChart(
              activeMachines: _activeMachines,
              idleMachines: _idleMachines,
              offlineMachines: _offlineMachines,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow() {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 1, child: LiveAlerts()),
          SizedBox(width: 16),
          Expanded(flex: 2, child: RecentActivity()),
        ],
      ),
    );
  }
}
