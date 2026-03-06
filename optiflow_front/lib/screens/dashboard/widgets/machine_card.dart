import 'package:flutter/material.dart';
import 'package:optiflow_scheduler/models/machine.dart';
import 'package:optiflow_scheduler/utils/app_colors.dart';

class MachineCard extends StatelessWidget {
  final Machine machine;

  const MachineCard({super.key, required this.machine});

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
          _buildTopRow(),
          const SizedBox(height: 24),
          if (machine.status == "ACTIVE" && machine.currentJobTitle != null)
            _buildActiveJobSection()
          else
            _buildSpacerHeight(85), // Keep card height consistent-ish
          const SizedBox(height: 24),
          _buildSpecsGrid(),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          _buildFooterStats(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getStatusColor(machine.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.print, color: _getStatusColor(machine.status), size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                machine.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${machine.type}\n${machine.location}",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color = _getStatusColor(machine.status);
    String label = machine.status;
    IconData icon = Icons.circle;

    if (machine.status == "ACTIVE") {
      label = "Busy";
      icon = Icons.access_time_filled;
      color = const Color(0xFFD946EF); // Pink
    } else if (machine.status == "MAINTENANCE") {
      icon = Icons.build_circle;
      color = AppColors.warning;
    } else if (machine.status == "BROKEN") {
      label = "Error";
      icon = Icons.error;
      color = AppColors.error;
    } else {
      label = "Idle";
      icon = Icons.check_circle;
      color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF4FF), // Very light pink
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                machine.currentJobTitle ?? "Unknown Job",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "${machine.progress}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFFD946EF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (machine.progress ?? 0) / 100,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD946EF)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                machine.currentJobUser ?? "Unknown User",
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                machine.timeLeft ?? "",
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpacerHeight(double height) {
    return SizedBox(height: height);
  }

  Widget _buildSpecsGrid() {
    return Row(
      children: [
        _buildSpecItem("Build Volume", machine.buildVolume),
        const SizedBox(width: 16),
        _buildSpecItem("Material", machine.material),
      ],
    );
    // Note: Resolution is in the design but space might be tight, can add if needed.
  }

  Widget _buildSpecItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStat("Utilization", "${machine.utilization}%"),
        _buildStat("Completed Jobs", "${machine.completedJobs}"),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "ACTIVE":
        return const Color(0xFFD946EF); // Pink
      case "MAINTENANCE":
        return AppColors.warning;
      case "BROKEN":
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
