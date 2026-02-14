import 'package:flutter/material.dart';
import 'package:optiflow_scheduler/utils/app_colors.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.surface,
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: 32),
          _buildMenuItem(0, Icons.dashboard_outlined, "Dashboard"),
          _buildMenuItem(1, Icons.print_outlined, "Machines"),
          _buildMenuItem(2, Icons.calendar_today_outlined, "Schedule"),
          _buildMenuItem(3, Icons.inventory_2_outlined, "Jobs"),
          _buildMenuItem(4, Icons.people_outline, "Team"),
          _buildMenuItem(5, Icons.analytics_outlined, "Analytics"),
          _buildMenuItem(6, Icons.settings_outlined, "Settings"),
          const Spacer(),
          _buildLogo(isFooter: true), // Placeholder for bottom logo
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogo({bool isFooter = false}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // Placeholder for logo
          Icon(Icons.circle, color: isFooter ? Colors.purple : Colors.pink, size: 32),
          const SizedBox(width: 12),
          if (!isFooter)
            const Text(
              "OptiFlow",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
