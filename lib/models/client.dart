class Client {
  const Client({
    required this.name,
    required this.project,
    required this.status,
    required this.budget,
    required this.deadline,
  });

  final String name;
  final String project;
  final String status;
  final double budget;
  final DateTime deadline;

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'] as String? ?? '',
      project: json['project'] as String? ?? '',
      status: json['status'] as String? ?? '',
      budget: (json['budget'] as num?)?.toDouble() ?? 0,
      deadline: DateTime.tryParse(json['deadline'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'project': project,
      'status': status,
      'budget': budget,
      'deadline': deadline.toIso8601String(),
    };
  }
}
