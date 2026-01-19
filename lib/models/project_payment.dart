class ProjectPayment {
  const ProjectPayment({
    required this.id,
    required this.projectId,
    required this.amount,
    required this.kind,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.paidDate,
  });

  final String id;
  final String projectId;
  final double amount;
  final String kind;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? paidDate;

  factory ProjectPayment.fromJson(Map<String, dynamic> json) {
    return ProjectPayment(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      kind: json['kind'] as String? ?? 'other',
      status: json['status'] as String? ?? 'planned',
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.tryParse(json['dueDate'] as String? ?? ''),
      paidDate: json['paidDate'] == null
          ? null
          : DateTime.tryParse(json['paidDate'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'amount': amount,
      'kind': kind,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
