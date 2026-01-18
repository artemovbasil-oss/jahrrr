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

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      client: json['client'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      stage: json['stage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client': client,
      'amount': amount,
      'date': date.toIso8601String(),
      'stage': stage,
    };
  }
}
