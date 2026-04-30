import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the current index for the bottom navigation bar
final bottomNavIndexProvider = StateProvider<int>(
  (ref) => 2,
); // default to Calendar (index 2)

// Provides the currently selected date on the calendar (defaults to day 8)
final selectedDateProvider = StateProvider<int>((ref) => 8);

// Mock provider to simulate Supabase real-time stream
final jobsProvider = StreamProvider<int>((ref) {
  return Stream.periodic(
    const Duration(seconds: 5),
    (count) => count,
  ).take(100);
});
