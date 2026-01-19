class RetainerSettings {
  const RetainerSettings({
    required this.amount,
    required this.frequency,
    required this.nextPaymentDate,
    required this.isEnabled,
    required this.updatedAt,
  });

  final double amount;
  final String frequency;
  final DateTime nextPaymentDate;
  final bool isEnabled;
  final DateTime updatedAt;

  factory RetainerSettings.fromJson(Map<String, dynamic> json) {
    return RetainerSettings(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      frequency: json['frequency'] as String? ?? 'once_month',
      nextPaymentDate:
          DateTime.tryParse(json['nextPaymentDate'] as String? ?? '') ?? DateTime.now(),
      isEnabled: json['isEnabled'] as bool? ?? true,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'frequency': frequency,
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'isEnabled': isEnabled,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
