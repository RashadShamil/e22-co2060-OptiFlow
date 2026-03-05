import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:optiflow_scheduler/models/booking.dart';
import 'package:optiflow_scheduler/models/machine.dart';
import 'package:optiflow_scheduler/services/api_service.dart';
import 'package:optiflow_scheduler/utils/app_colors.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ApiService _apiService = ApiService();
  List<Booking> _bookings = [];
  List<Machine> _machines = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final machines = await _apiService.fetchMachines();
    final bookings = await _apiService.fetchBookings();

    if (mounted) {
      setState(() {
        _machines = machines;
        _bookings = bookings;
        _isLoading = false;
      });
    }
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
          _buildDateNavigator(),
          const SizedBox(height: 32),
          _buildTimeline(),
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
              "Schedule",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Manage machine bookings and prevent scheduling conflicts",
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
        Container(
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
                "New Booking",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateNavigator() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(
                        const Duration(days: 1),
                      );
                    });
                  },
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(
                        const Duration(days: 1),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Bookings",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "9",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "2 conflicts",
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          _buildTimelineHeader(),
          const Divider(height: 1),
          // Machine Rows
          ..._machines.map((machine) => _buildMachineTimelineRow(machine)),
          // Legend Footer
          const Divider(height: 1),
          _buildTimelineFooter(),
        ],
      ),
    );
  }

  Widget _buildTimelineHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          const SizedBox(width: 200), // Space for Machine Name column
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(11, (index) {
                // 8 AM to 6 PM = 11 slots
                final hour = 8 + index;
                final ampm = hour < 12 ? "AM" : (hour == 12 ? "PM" : "PM");
                final hourDisplay = hour <= 12 ? hour : hour - 12;

                return Expanded(
                  child: Center(
                    child: Text(
                      "$hourDisplay $ampm",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineTimelineRow(Machine machine) {
    // Check if there are bookings for this machine
    final machineBookings = _bookings
        .where((b) => b.machineId == machine.id)
        .toList();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Machine Info Column
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  machine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  machine.id.length > 5
                      ? '5h booked'
                      : '4h booked', // Mock utilization text
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Timeline bar
          Expanded(
            child: Stack(
              children: [
                // Grid lines background
                Row(
                  children: List.generate(11, (index) {
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.grey.shade100),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                // Booking blocks
                ...machineBookings.map(
                  (booking) => _buildBookingBlock(booking),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingBlock(Booking booking) {
    // Calculate position and width based on time
    // Timeline is 8 AM to 6 PM (10 hours total span displayed + 1 for end marker) = 10 hours width
    // Each hour is 1/11th of width approximately if we count slots,
    // but header showed 11 labels. Let's assume 8AM is 0% and 6PM is 100%.
    // Total span: 10 hours (8 to 18).

    final startHour = booking.startTime.hour + (booking.startTime.minute / 60);
    final offsetStart = startHour - 8; // Offset from 8 AM
    if (offsetStart < 0) return const SizedBox(); // Before 8 AM

    // Calculate percent position
    // Total timeline width = 100%
    // 1 hour = 10%

    final leftPercent = offsetStart * 10; // 10% per hour
    final widthPercent = booking.durationHours * 10;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final left =
            totalWidth *
            (leftPercent / 100) /
            1.1; // Adjust scale for 11 columns
        final width = totalWidth * (widthPercent / 100) / 1.1;

        Color color;
        if (booking.status == "CONFLICT") {
          color = AppColors.error;
        } else if (booking.priority == "High") {
          color = const Color(0xFF0EA5E9); // Blue
        } else if (booking.priority == "Medium") {
          color = const Color(0xFFD946EF); // Pink
        } else {
          color = const Color(0xFFF97316); // Orange
        }

        return Positioned(
          left: left,
          top: 10,
          bottom: 10,
          width: width,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  booking.jobTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                Text(
                  "${booking.durationHours}h • ${booking.priority} Priority",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          const Text(
            "Tip: Drag blocks to reschedule",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 24),
          _buildLegendInd(AppColors.primary, "Active booking"),
          const SizedBox(width: 16),
          _buildLegendInd(AppColors.error, "Conflict (double-booking)"),
        ],
      ),
    );
  }

  Widget _buildLegendInd(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}
