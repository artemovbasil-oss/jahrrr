import 'retainer_settings.dart';

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
    final avatarColorHex = json['avatarColorHex'] as String? ?? '';
    final retainerSettingsJson = json['retainerSettings'] as Map<String, dynamic>?;
    final parsedRetainer = retainerSettingsJson == null
        ? _buildLegacyRetainerSettings(legacyProject, legacyBudget)
        : RetainerSettings.fromJson(retainerSettingsJson);

    return Client(
      id: id,
      name: json['name'] as String? ?? '',
      type: type,
      contactPerson: json['contactPerson'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      telegram: json['telegram'] as String?,
      plannedBudget: (json['plannedBudget'] as num?)?.toDouble() ?? legacyBudget,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      avatarColorHex: avatarColorHex,
      retainerSettings: type == 'retainer' ? parsedRetainer : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'telegram': telegram,
      'plannedBudget': plannedBudget,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'avatarColorHex': avatarColorHex,
      'retainerSettings': retainerSettings?.toJson(),
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
