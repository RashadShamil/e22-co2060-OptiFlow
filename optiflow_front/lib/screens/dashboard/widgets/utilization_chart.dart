import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:optiflow_scheduler/utils/app_colors.dart';

class UtilizationChart extends StatelessWidget {
  const UtilizationChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Machine Utilization",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 70,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFFD946EF), // Pink
                        value: 68,
                        title: '',
                        radius: 20,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: AppColors.background,
                        value: 32,
                        title: '',
                        radius: 20,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "68%",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "Active",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildLegendItem("Active Machines", "11 of 16", AppColors.textPrimary),
          const SizedBox(height: 8),
          _buildLegendItem("Idle", "5", AppColors.textSecondary),
          const SizedBox(height: 8),
          _buildLegendItem("Offline", "2", AppColors.error),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
