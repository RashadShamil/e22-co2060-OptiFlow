import 'package:flutter/material.dart';
import 'package:optiflow_scheduler/models/machine.dart';
import 'package:optiflow_scheduler/services/api_service.dart';
import 'package:optiflow_scheduler/utils/app_colors.dart';
import 'package:optiflow_scheduler/screens/dashboard/widgets/machine_card.dart';
import 'package:optiflow_scheduler/screens/add_machine_screen.dart';

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({super.key});

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  final ApiService _apiService = ApiService();
  List<Machine> _machines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMachines();
  }

  Future<void> _fetchMachines() async {
    final machines = await _apiService.fetchMachines();
    setState(() {
      _machines = machines;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildSearchBar(),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive Grid
              int crossAxisCount = constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
              double aspectRatio = crossAxisCount == 1 ? 1.5 : 0.85; // Adjust aspect ratio based on width
              // Actually, simplified approach: use Wrap or GridView with fixed mainAxisExtent logic if possible, 
              // but standard GridView.builder works fine for now.
              // Let's refine aspect ratio: MachineCard is roughly 400px tall. 
              // If column width is ~400px, aspect ratio ~1.
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.9, // Tweak this for card height
                ),
                itemCount: _machines.length,
                itemBuilder: (context, index) {
                  return MachineCard(machine: _machines[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Machines",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Manage and monitor all print shop equipment",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddMachineScreen()),
            );
            if (result == true) {
              _fetchMachines(); // Refresh list if machine was added
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  "Add Machine",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: AppColors.textSecondary),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search machines...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Row(
            children: [
              Icon(Icons.filter_list, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                "All Status",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "ACTIVE":
        return AppColors.success;
      case "MAINTENANCE":
        return AppColors.warning;
      case "BROKEN":
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

