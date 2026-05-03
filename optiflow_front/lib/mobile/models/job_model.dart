import 'package:intl/intl.dart';

/// Represents a print job visible in the Job Market.
class JobModel {
  final String id;
  final String title;
  final String clientName;
  final int totalQuantity;
  final String status;
  final DateTime? deadline;
  final String? assignedTo;

  const JobModel({
    required this.id,
    required this.title,
    required this.clientName,
    required this.totalQuantity,
    required this.status,
    this.deadline,
    this.assignedTo,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDeadline;
    try {
      final raw = json['deadline'];
      if (raw != null) parsedDeadline = DateTime.parse(raw).toLocal();
    } catch (_) {}

    return JobModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled',
      clientName: json['client_name'] ?? 'Unknown Client',
      totalQuantity: json['total_quantity'] ?? 0,
      status: json['status'] ?? 'OPEN',
      deadline: parsedDeadline,
      assignedTo: json['assigned_to'],
    );
  }

  /// Returns e.g. "Due May 15" or "No deadline"
  String get formattedDeadline {
    if (deadline == null) return 'No deadline';
    return 'Due ${DateFormat('MMM d').format(deadline!)}';
  }
}
