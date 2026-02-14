import 'package:flutter/material.dart';
import 'package:optiflow_scheduler/screens/dashboard/widgets/activity_section.dart';
import 'package:optiflow_scheduler/screens/dashboard/widgets/revenue_chart.dart';
import 'package:optiflow_scheduler/screens/dashboard/widgets/sidebar.dart';
import 'package:optiflow_scheduler/screens/dashboard/widgets/stat_card.dart';
import 'package:optiflow_scheduler/screens/dashboard/widgets/utilization_chart.dart';
import 'package:optiflow_scheduler/utils/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

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
          Expanded(
            child: SingleChildScrollView(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Welcome back, John. Here's your shop overview for today.",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return const Row(
      children: [
        Expanded(
          child: StatCard(
            title: "Today's Revenue",
            value: "\$12,847",
            icon: Icons.attach_money,
            iconColor: Colors.purple,
            percentage: 12.5,
            comparisonText: "vs yesterday",
            isIncreasePositive: true,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: "Active Jobs",
            value: "24",
            icon: Icons.inventory_2_outlined,
            iconColor: Colors.blue,
            percentage: 8.2,
            comparisonText: "from last week",
            isIncreasePositive: true,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: "Machine Uptime",
            value: "94.2%",
            icon: Icons.print_outlined,
            iconColor: Colors.green,
            percentage: -2.1,
            comparisonText: "vs last week",
            isIncreasePositive: false, // Decrease in uptime is bad
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: "Avg Completion",
            value: "4.2h",
            icon: Icons.timer_outlined,
            iconColor: Colors.orange,
            percentage: 15, // "Faster" means time decreased? Design says "15% faster" with green upward arrow?
            // Usually faster means less time, so -15% time. But design might show +15% speed.
            // Let's assume +15% metric improvement.
            comparisonText: "faster",
            isIncreasePositive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsRow() {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: RevenueChart(),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: UtilizationChart(),
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
          Expanded(
            flex: 1,
            child: LiveAlerts(),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: RecentActivity(),
          ),
        ],
      ),
    );
  }
}
