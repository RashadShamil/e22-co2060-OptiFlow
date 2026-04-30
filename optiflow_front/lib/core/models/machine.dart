class Machine {
  final String id;
  final String name;
  final String status; // "ACTIVE", "MAINTENANCE", "BROKEN", "IDLE"
  final String type;
  final String location;
  final String buildVolume;
  final String material;
  final String resolution;
  final int utilization;
  final int completedJobs;
  
  // Active Job Details (nullable)
  final String? currentJobTitle;
  final String? currentJobUser;
  final int? progress; // 0-100
  final String? timeLeft;

  Machine({
    required this.id,
    required this.name,
    required this.status,
    this.type = "FDM Printer",
    this.location = "Zone A - Station 1",
    this.buildVolume = "250 x 210 x 210 mm",
    this.material = "PLA, PETG, ABS",
    this.resolution = "0.05mm",
    this.utilization = 0,
    this.completedJobs = 0,
    this.currentJobTitle,
    this.currentJobUser,
    this.progress,
    this.timeLeft,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    String status = json['status'] ?? 'UNKNOWN';
    
    // Simulate extra data for UI demo purposes since backend is simple
    // In a real app, these would come from the API
    bool isBusy = status == "ACTIVE" || status == "BUSY";
    
    return Machine(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Machine',
      status: status,
      type: json['type'] ?? "FDM Printer", // Default if missing
      location: "Zone A - Station ${json['id'].toString().substring(0,1)}",
      utilization: 45 + (json['name'].toString().length * 2), // Fake calc
      completedJobs: 100 + (json['name'].toString().length * 5),
      
      // Simulate active job if status is ACTIVE
      currentJobTitle: isBusy ? "Prototype Housing v2" : null,
      currentJobUser: isBusy ? "Sarah Chen" : null,
      progress: isBusy ? 67 : null,
      timeLeft: isBusy ? "34m remaining" : null,
    );
  }
}
