import 'package:flutter/material.dart';
import 'package:optiflow_scheduler/slices/engine/dashboard/widgets/activity_section.dart';
import 'package:optiflow_scheduler/core/services/api_service.dart';
import 'package:optiflow_scheduler/slices/engine/dashboard/widgets/revenue_chart.dart';
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
  final ApiService _apiService = ApiService();
  double _totalRevenue = 0;
  int _activeJobsCount = 0;
  double _machineUptime = 0;
  int _activeMachines = 0;
  int _idleMachines = 0;
  int _offlineMachines = 0;
  List<double> _weeklyRevenue = List.filled(7, 0.0);
  double _avgCompletionHours = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final jobs = await _apiService.fetchJobs();
      final machines = await _apiService.fetchMachines();

      double revenue = 0;
      int activeJobs = 0;
      List<double> weeklyRev = List.filled(7, 0.0);
      for (var job in jobs) {
        revenue += job.price;
        if (job.status == "OPEN" || job.status == "IN_PROGRESS") {
          activeJobs++;
        }
        // Mock weekly revenue based on job ID length or actual date if available
        // For now distribute total quantity / price across random days
        final dayIndex = job.id.hashCode % 7;
        weeklyRev[dayIndex] += job.price.toDouble(); // Mock calculation
      }

      int activeM = machines.where((m) => m.status == "ACTIVE").length;
      int idleM = machines.where((m) => m.status == "IDLE").length;
      int offlineM = machines.where((m) => m.status == "OFFLINE").length;
      
      double uptime = machines.isEmpty
          ? 0
          : (activeM / machines.length) * 100;

      // Compute avg completion from real task data
      double avgHours = 0.0;
      try {
        final allTasks = await _apiService.fetchAllTasks();
        final completedWithTimes = allTasks.where((t) =>
          t['status'] == 'COMPLETED' &&
          t['started_at'] != null &&
          t['completed_at'] != null
        ).toList();
        if (completedWithTimes.isNotEmpty) {
          double totalHours = 0;
          for (final t in completedWithTimes) {
            final start = DateTime.tryParse(t['started_at'].toString());
            final end = DateTime.tryParse(t['completed_at'].toString());
            if (start != null && end != null) {
              totalHours += end.difference(start).inMinutes / 60.0;
            }
          }
          avgHours = totalHours / completedWithTimes.length;
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _totalRevenue = revenue > 0 ? revenue : (jobs.fold(0.0, (sum, j) => sum + j.price));
          _activeJobsCount = activeJobs;
          _machineUptime = uptime;
          _activeMachines = activeM;
          _idleMachines = idleM;
          _offlineMachines = offlineM;
          _weeklyRevenue = weeklyRev;
          _avgCompletionHours = avgHours;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          // Main Content
          Expanded(child: _buildCurrentPage()),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const MachinesScreen();
      case 2:
        return const ScheduleScreen();
      case 3:
        return const JobsScreen();
      case 4:
        return const TeamScreen();
      case 5:
        return const AnalyticsScreen();
      case 6:
        return const SettingsScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Welcome back to OptiFlow. Here is your shop's performance today.",
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
            title: "Today's Revenue",
            value: "\$${_totalRevenue.toStringAsFixed(0)}",
            icon: Icons.monetization_on_rounded,
            iconColor: AppColors.secondary,
            percentage: 12.5,
            comparisonText: "vs yesterday",
            isIncreasePositive: true,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Active Jobs",
            value: "$_activeJobsCount",
            icon: Icons.inventory_2_rounded,
            iconColor: AppColors.info,
            percentage: 8.2,
            comparisonText: "from last week",
            isIncreasePositive: true,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Machine Uptime",
            value: "${_machineUptime.toStringAsFixed(1)}%",
            icon: Icons.precision_manufacturing_rounded,
            iconColor: AppColors.success,
            percentage: -2.1,
            comparisonText: "vs last week",
            isIncreasePositive: false,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Avg Completion",
            value: _avgCompletionHours > 0 ? "${_avgCompletionHours.toStringAsFixed(1)}h" : "N/A",
            icon: Icons.timer_rounded,
            iconColor: AppColors.warning,
            percentage: 0,
            comparisonText: "per task",
            isIncreasePositive: false,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsRow() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: RevenueChart(weeklyRevenue: _weeklyRevenue)),
          const SizedBox(width: 24),
          Expanded(flex: 3, child: UtilizationChart(
            activeMachines: _activeMachines,
            idleMachines: _idleMachines,
            offlineMachines: _offlineMachines,
          )),
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
