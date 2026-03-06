import 'dart:convert';
import 'package:optiflow_scheduler/models/booking.dart';
import 'package:http/http.dart' as http;
import 'package:optiflow_scheduler/models/job.dart';
import 'package:optiflow_scheduler/models/machine.dart';

class ApiService {
  // Use 127.0.0.1 for Windows/Desktop.
  // If running on Android emulator, use 10.0.2.2
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<List<Machine>> fetchMachines() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/machines"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> machinesJson = data['machines'];
        return machinesJson.map((json) => Machine.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load machines");
      }
    } catch (e) {
      print("Error fetching machines: $e");
      // Return empty list instead of crashing
      return [];
    }
  }

  Future<List<Job>> fetchJobs() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/jobs"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> jobsJson = data['jobs'];
        return jobsJson.map((json) => Job.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load jobs");
      }
    } catch (e) {
      print("Error fetching jobs: $e");
      return [];
    }
  }

  // Mock method for now since backend doesn't have full schedule endpoint yet
  Future<List<Booking>> fetchBookings() async {
    // Return dummy data matching the design for demo purposes
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
    final now = DateTime.now();
    final today9am = DateTime(now.year, now.month, now.day, 9);

    return [
      Booking(
        id: "1",
        machineId: "1",
        machineName: "Ultimaker S5",
        jobTitle: "Housing Prototype v3",
        userName: "Sarah Chen",
        startTime: DateTime(now.year, now.month, now.day, 8),
        durationHours: 3,
        priority: "High",
      ),
      Booking(
        id: "2",
        machineId: "1",
        machineName: "Ultimaker S5",
        jobTitle: "Gear Assembly",
        userName: "Mike Johnson",
        startTime: DateTime(now.year, now.month, now.day, 11), // 11 AM
        durationHours: 2,
        priority: "Medium",
      ),
      Booking(
        id: "3",
        machineId: "2",
        machineName: "Formlabs Form 3",
        jobTitle: "Miniature Parts",
        userName: "Emily Davis",
        startTime: DateTime(now.year, now.month, now.day, 9, 30), // 9:30 AM
        durationHours: 4,
        priority: "Medium",
      ),
      Booking(
        id: "4",
        machineId: "3",
        machineName: "Prusa i3 MK3",
        jobTitle: "Bracket Set",
        userName: "John Doe",
        startTime: DateTime(now.year, now.month, now.day, 10), // 10 AM
        durationHours: 3,
        priority: "Low",
      ),
      Booking(
        id: "5",
        machineId: "3",
        machineName: "Prusa i3 MK3",
        jobTitle: "Emergency Job",
        userName: "Admin",
        startTime: DateTime(
          now.year,
          now.month,
          now.day,
          12,
          30,
        ), // 12:30 PM - Conflict
        durationHours: 2,
        priority: "High",
        status: "CONFLICT",
      ),
      Booking(
        id: "6",
        machineId: "4",
        machineName: "Ultimaker S3",
        jobTitle: "Large Print Job",
        userName: "User A",
        startTime: DateTime(now.year, now.month, now.day, 8),
        durationHours: 5,
        priority: "Medium",
      ),
      Booking(
        id: "7",
        machineId: "5",
        machineName: "Formlabs 3L",
        jobTitle: "Dental Models",
        userName: "Dr. Smith",
        startTime: DateTime(now.year, now.month, now.day, 14), // 2 PM
        durationHours: 3,
        priority: "High",
      ),
      Booking(
        id: "8",
        machineId: "6",
        machineName: "Stratasys F370",
        jobTitle: "Enclosure Parts",
        userName: "Team B",
        startTime: DateTime(now.year, now.month, now.day, 9, 30),
        durationHours: 4,
        priority: "Medium",
      ),
    ];
  }
}
