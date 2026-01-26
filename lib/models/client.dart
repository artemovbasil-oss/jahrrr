import 'retainer_settings.dart';

const String _kDefaultAvatarColorHex = '#2D6EF8';

class Client {
  const Client({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.avatarColorHex,
    this.contactPerson,
    this.phone,
    this.email,
    this.telegram,
    this.notes,
    this.plannedBudget,
    this.retainerSettings,
  });

  final String id;
  final String name;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String avatarColorHex;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? telegram;
  final String? notes;
  final double? plannedBudget;
  final RetainerSettings? retainerSettings;

  factory Client.fromJson(Map<String, dynamic> json) {
    final legacyProject = json['project'] as String?;
    final legacyBudget = (json['budget'] as num?)?.toDouble();
    final legacyType = legacyProject?.toLowerCase().startsWith('retainer') == true
        ? 'retainer'
        : 'project';
    final type = json['type'] as String? ?? legacyType;
    final id = json['id'] as String? ?? (json['name'] as String? ?? '');
    final avatarColorHex = _normalizeAvatarColorHex(
      json['avatar_color'] as String? ??
          json['color'] as String? ??
          json['avatarColorHex'] as String?,
    );
    final retainerSettingsJson =
        (json['retainer_settings'] as Map<String, dynamic>?) ??
        (json['retainerSettings'] as Map<String, dynamic>?);
    final parsedRetainer = retainerSettingsJson == null
        ? _buildLegacyRetainerSettings(legacyProject, legacyBudget)
        : RetainerSettings.fromJson(retainerSettingsJson);

    return Client(
      id: id,
      name: json['name'] as String? ?? '',
      type: type,
      contactPerson:
          json['contact_person'] as String? ?? json['contactPerson'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      telegram: json['telegram'] as String?,
      notes: json['notes'] as String?,
      plannedBudget:
          (json['planned_budget'] as num?)?.toDouble() ??
          (json['plannedBudget'] as num?)?.toDouble() ??
          legacyBudget,
      createdAt: DateTime.tryParse(
            json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
            json['updated_at'] as String? ?? json['updatedAt'] as String? ?? '',
          ) ??
          DateTime.now(),
      avatarColorHex: avatarColorHex,
      retainerSettings: type == 'retainer' ? parsedRetainer : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'telegram': telegram,
      'notes': notes,
      'planned_budget': plannedBudget,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'avatar_color': _normalizeAvatarColorHex(avatarColorHex),
      'retainer_settings': retainerSettings?.toJson(),
    };
  }
}

RetainerSettings? _buildLegacyRetainerSettings(String? projectSummary, double? budget) {
  if (projectSummary == null) {
    return null;
  }
  if (!projectSummary.toLowerCase().startsWith('retainer')) {
    return null;
  }
  final frequency = projectSummary.contains('Twice a month') ? 'twice_month' : 'once_month';
  return RetainerSettings(
    amount: budget ?? 0,
    frequency: frequency,
    nextPaymentDate: DateTime.now(),
    isEnabled: true,
    updatedAt: DateTime.now(),
  );
}

String _normalizeAvatarColorHex(String? value) {
  final cleaned = value?.replaceAll('#', '').trim() ?? '';
  if (cleaned.isEmpty) {
    return _kDefaultAvatarColorHex;
  }
  final normalized = cleaned.toUpperCase();
  return '#$normalized';
}
