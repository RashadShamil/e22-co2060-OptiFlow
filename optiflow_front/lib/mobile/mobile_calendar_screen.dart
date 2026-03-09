import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'providers.dart';

class MobileCalendarScreen extends ConsumerWidget {
  const MobileCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the selected date (defaulting to 8th of March as per original design)
    final selectedDay = ref.watch(selectedDateProvider);
    return Scaffold(
      backgroundColor: MobileTheme.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'OptiFlow',
          style: TextStyle(
            color: MobileTheme.neonBlue,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: MobileTheme.magenta),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Month Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.chevron_left, color: MobileTheme.neonBlue),
                  const Text(
                    'March 2026',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: MobileTheme.neonBlue),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Calendar Grid
            _buildCalendarGrid(selectedDay, ref),

            const SizedBox(height: 24),
            // Divider
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 16),

            // Job Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassContainer(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: MobileTheme.magenta,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Poster A3 x500',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Job #4057 - Queued',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(int selectedDay, WidgetRef ref) {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Days Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: MobileTheme.neonBlue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          // Dates Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8,
            ),
            itemCount: 42, // up to 6 weeks
            itemBuilder: (context, index) {
              int startOffset = 0; // Sun
              if (index < startOffset || index >= startOffset + 31) {
                // Next month dates
                int nextMonthDay = index - (startOffset + 31) + 1;
                return _buildLightDayCell(day: nextMonthDay);
              }
              int day = index - startOffset + 1;

              bool isSelected = day == selectedDay;
              bool isMagentaHighlight = day == 27;

              bool hasDots = [
                3,
                6,
                8,
                9,
                12,
                15,
                18,
                21,
                24,
                30,
                3,
              ].contains(day);

              return GestureDetector(
                onTap: () {
                  ref.read(selectedDateProvider.notifier).state = day;
                },
                behavior: HitTestBehavior.opaque,
                child: _buildDayCell(
                  day: day,
                  isSelected: isSelected,
                  isMagentaHighlight: isMagentaHighlight,
                  hasDots: hasDots,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLightDayCell({required int day}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 10), // placeholder for dots
      ],
    );
  }

  Widget _buildDayCell({
    required int day,
    required bool isSelected,
    required bool isMagentaHighlight,
    required bool hasDots,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMagentaHighlight
                ? MobileTheme.magenta
                : Colors.transparent,
            border: isSelected
                ? Border.all(color: MobileTheme.neonBlue, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        if (hasDots) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: MobileTheme.emeraldGreen,
                  shape: BoxShape.circle,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 2),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: MobileTheme.emeraldGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: MobileTheme.emeraldGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ] else
          const SizedBox(height: 10), // placeholder for dots
      ],
    );
  }
}
