class Project {
  const Project({
    required this.clientName,
    required this.name,
    required this.amount,
    required this.stage,
    required this.nextStageDeadline,
    this.depositPercent,
  });

  factory Project.empty() {
    return Project(
      clientName: '',
      name: '',
      amount: 0,
      stage: '',
      nextStageDeadline: DateTime.now(),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      clientName: json['clientName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      stage: json['stage'] as String? ?? '',
      nextStageDeadline:
          DateTime.tryParse(json['nextStageDeadline'] as String? ?? '') ?? DateTime.now(),
      depositPercent: (json['depositPercent'] as num?)?.toDouble(),
    );
  }

  final String clientName;
  final String name;
  final double amount;
  final String stage;
  final double? depositPercent;
  final DateTime nextStageDeadline;

  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'name': name,
      'amount': amount,
      'stage': stage,
      'nextStageDeadline': nextStageDeadline.toIso8601String(),
      'depositPercent': depositPercent,
    };
  }
}
