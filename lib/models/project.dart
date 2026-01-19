class Project {
  const Project({
    required this.id,
    required this.clientId,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deadlineDate,
  });

  final String id;
  final String clientId;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deadlineDate;

  factory Project.empty() {
    return Project(
      id: '',
      clientId: '',
      title: '',
      status: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    final legacyDeadline =
        DateTime.tryParse(json['nextStageDeadline'] as String? ?? '');
    final legacyStage = json['stage'] as String?;
    return Project(
      id: json['id'] as String? ?? json['name'] as String? ?? '',
      clientId: json['clientId'] as String? ?? json['clientName'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      status: json['status'] as String? ?? _mapLegacyStage(legacyStage) ?? '',
      deadlineDate: json['deadlineDate'] == null
          ? legacyDeadline
          : DateTime.tryParse(json['deadlineDate'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'title': title,
      'status': status,
      'deadlineDate': deadlineDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

String? _mapLegacyStage(String? legacyStage) {
  if (legacyStage == null) {
    return null;
  }
  return switch (legacyStage) {
    'First meeting' => 'first_meeting',
    'Deposit received' => 'deposit_received',
    'In progress' => 'in_progress',
    'Awaiting feedback' => 'awaiting_feedback',
    'Returned for revision' => 'returned_for_revision',
    'Renegotiating budget' => 'renegotiating_budget',
    'Project on hold' => 'project_on_hold',
    'Payment received in full' => 'payment_received_in_full',
    _ => legacyStage,
  };
}
