import 'package:flutter/material.dart';
import 'package:optiflow_scheduler/core/utils/app_colors.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          right: BorderSide(color: AppColors.surfaceLight.withOpacity(0.5), width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildLogo(),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionLabel("OVERVIEW"),
                _buildMenuItem(0, Icons.dashboard_rounded, "Dashboard"),
                _buildMenuItem(5, Icons.analytics_rounded, "Analytics"),
                const SizedBox(height: 24),
                _buildSectionLabel("OPERATIONS"),
                _buildMenuItem(1, Icons.print_rounded, "Machines"),
                _buildMenuItem(3, Icons.inventory_2_rounded, "Jobs"),
                _buildMenuItem(2, Icons.calendar_month_rounded, "Schedule"),
                const SizedBox(height: 24),
                _buildSectionLabel("ADMIN"),
                _buildMenuItem(4, Icons.people_rounded, "Team"),
                _buildMenuItem(6, Icons.settings_rounded, "Settings"),
              ],
            ),
          ),
          _buildBottomProfile(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 12, top: 8),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary.withOpacity(0.5),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              "assets/images/logo.png",
              height: 48,
              width: 48,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.blur_circular, color: AppColors.primary, size: 48);
              },
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "OptiFlow",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    final bool isSelected = widget.selectedIndex == index;
    final bool isHovered = _hoveredIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: GestureDetector(
          onTap: () => widget.onItemSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected 
                  ? null 
                  : (isHovered ? AppColors.surfaceLight.withOpacity(0.5) : Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : (isHovered ? AppColors.textPrimary : AppColors.textSecondary),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isHovered ? AppColors.textPrimary : AppColors.textSecondary),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomProfile() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.surfaceLight.withOpacity(0.5), width: 1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Admin User",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "admin@optiflow.com",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
