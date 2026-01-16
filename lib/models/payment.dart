class Payment {
  const Payment({
    required this.client,
    required this.amount,
    required this.date,
    required this.stage,
  });

  final String client;
  final double amount;
  final DateTime date;
  final String stage;
}
