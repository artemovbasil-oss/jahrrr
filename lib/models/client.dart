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
}
