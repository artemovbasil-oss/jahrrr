class Milestone {
  const Milestone({
    required this.title,
    required this.client,
    required this.dueDate,
    required this.progress,
  });

  final String title;
  final String client;
  final DateTime dueDate;
  final double progress;
}
