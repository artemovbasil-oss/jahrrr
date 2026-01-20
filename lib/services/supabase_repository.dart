import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/client.dart';
import '../models/project.dart';
import '../models/project_payment.dart';
import '../models/retainer_settings.dart';
import '../models/user_profile.dart';

enum ImportMode { replace, merge }

class SupabaseRepository {
  SupabaseRepository(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  UserProfile? currentUserProfile() {
    final user = currentUser;
    if (user == null) {
      return null;
    }
    final name = user.userMetadata?['name'] as String?;
    return UserProfile(
      name: name ?? '',
      email: user.email ?? '',
      updatedAt: DateTime.now(),
    );
  }

  Future<void> updateProfileName(String name) async {
    await _client.auth.updateUser(
      UserAttributes(data: {'name': name}),
    );
  }

  Future<Project> createProject(Project project) async {
    final userId = _requireUserId();
    final payload = _projectInsertPayload(project, userId);
    try {
      final row = await _client
          .from('projects')
          .insert(payload)
          .select()
          .single();
      return _projectFromRow(row as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      _logPostgrestError(
        operation: 'projects.insert',
        error: error,
        payload: payload,
      );
      rethrow;
    } catch (error) {
      _logUnknownError(
        operation: 'projects.insert',
        error: error,
        payload: payload,
      );
      rethrow;
    }
  }

  Future<List<Client>> fetchClients() async {
    final userId = _requireUserId();
    final clientRows = await _client
        .from('clients')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    final retainerRows = await _client
        .from('retainer_settings')
        .select()
        .eq('user_id', userId);
    final retainers = <String, Map<String, dynamic>>{
      for (final row in retainerRows)
        (row as Map<String, dynamic>)['client_id'] as String: row,
    };
    return clientRows.map<Client>((row) {
      final clientRow = row as Map<String, dynamic>;
      return _clientFromRow(
        clientRow,
        retainers[clientRow['id'] as String],
      );
    }).toList();
  }

  Future<List<Project>> fetchProjects() async {
    final userId = _requireUserId();
    final rows = await _client
        .from('projects')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return rows
        .map<Project>((row) => _projectFromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProjectPayment>> fetchProjectPayments() async {
    final userId = _requireUserId();
    final rows = await _client
        .from('project_payments')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return rows
        .map<ProjectPayment>(
          (row) => _projectPaymentFromRow(row as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> syncAll({
    required List<Client> clients,
    required List<Project> projects,
    required List<ProjectPayment> payments,
  }) async {
    final userId = _requireUserId();
    await _syncClients(userId, clients);
    await _syncProjects(userId, projects);
    await _syncPayments(userId, payments);
  }

  Future<Map<String, dynamic>> exportData() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('No user session available.');
    }
    final clients =
        await _client.from('clients').select().eq('user_id', user.id);
    final retainers =
        await _client.from('retainer_settings').select().eq('user_id', user.id);
    final projects =
        await _client.from('projects').select().eq('user_id', user.id);
    final payments =
        await _client.from('project_payments').select().eq('user_id', user.id);

    return {
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'userEmail': user.email,
      'data': {
        'clients': clients,
        'retainer_settings': retainers,
        'projects': projects,
        'project_payments': payments,
      },
    };
  }

  Future<void> importData(
    String rawPayload, {
    required ImportMode mode,
  }) async {
    final userId = _requireUserId();
    final decoded = jsonDecode(rawPayload) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? {};
    final clients = _sanitizeImportList(data['clients'], userId);
    final retainers = _sanitizeImportList(data['retainer_settings'], userId);
    final projects = _sanitizeImportList(data['projects'], userId);
    final payments = _sanitizeImportList(data['project_payments'], userId);

    if (mode == ImportMode.replace) {
      await _client.from('project_payments').delete().eq('user_id', userId);
      await _client.from('projects').delete().eq('user_id', userId);
      await _client.from('retainer_settings').delete().eq('user_id', userId);
      await _client.from('clients').delete().eq('user_id', userId);
    }

    if (clients.isNotEmpty) {
      await _client.from('clients').upsert(clients);
    }
    if (retainers.isNotEmpty) {
      await _client.from('retainer_settings').upsert(retainers);
    }
    if (projects.isNotEmpty) {
      await _client.from('projects').upsert(projects);
    }
    if (payments.isNotEmpty) {
      await _client.from('project_payments').upsert(payments);
    }
  }

  Future<void> _syncClients(String userId, List<Client> clients) async {
    final existing = await _client
        .from('clients')
        .select('id')
        .eq('user_id', userId);
    final existingIds = existing
        .map<String>((row) => row['id'] as String)
        .toSet();
    final currentIds = clients.map((client) => client.id).toSet();
    final toDelete = existingIds.difference(currentIds).toList();
    if (toDelete.isNotEmpty) {
      await _client.from('clients').delete().inFilter('id', toDelete);
    }
    final payload = clients
        .map((client) => _clientToRow(client, userId))
        .toList();
    if (payload.isNotEmpty) {
      await _client.from('clients').upsert(payload);
    }

    final retainerExisting = await _client
        .from('retainer_settings')
        .select('client_id')
        .eq('user_id', userId);
    final retainerExistingIds = retainerExisting
        .map<String>((row) => row['client_id'] as String)
        .toSet();
    final retainerPayload = clients
        .where((client) => client.retainerSettings != null)
        .map((client) => _retainerToRow(client, userId))
        .toList();
    final retainerIds =
        retainerPayload.map((row) => row['client_id'] as String).toSet();
    final retainerDelete = retainerExistingIds.difference(retainerIds).toList();
    if (retainerDelete.isNotEmpty) {
      await _client.from('retainer_settings').delete().inFilter(
            'client_id',
            retainerDelete,
          );
    }
    if (retainerPayload.isNotEmpty) {
      await _client.from('retainer_settings').upsert(retainerPayload);
    }
  }

  Future<void> _syncProjects(String userId, List<Project> projects) async {
    final existing = await _client
        .from('projects')
        .select('id')
        .eq('user_id', userId);
    final existingIds = existing
        .map<String>((row) => row['id'] as String)
        .toSet();
    final currentIds = projects.map((project) => project.id).toSet();
    final toDelete = existingIds.difference(currentIds).toList();
    if (toDelete.isNotEmpty) {
      await _client.from('projects').delete().inFilter('id', toDelete);
    }
    final payload =
        projects.map((project) => _projectToRow(project, userId)).toList();
    if (payload.isNotEmpty) {
      await _client.from('projects').upsert(payload);
    }
  }

  Future<void> _syncPayments(
    String userId,
    List<ProjectPayment> payments,
  ) async {
    final existing = await _client
        .from('project_payments')
        .select('id')
        .eq('user_id', userId);
    final existingIds = existing
        .map<String>((row) => row['id'] as String)
        .toSet();
    final currentIds = payments.map((payment) => payment.id).toSet();
    final toDelete = existingIds.difference(currentIds).toList();
    if (toDelete.isNotEmpty) {
      await _client.from('project_payments').delete().inFilter('id', toDelete);
    }
    final payload = payments
        .map((payment) => _paymentToRow(payment, userId))
        .toList();
    if (payload.isNotEmpty) {
      await _client.from('project_payments').upsert(payload);
    }
  }

  List<Map<String, dynamic>> _sanitizeImportList(dynamic raw, String userId) {
    if (raw is! List) {
      return [];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (row) => {
            ...row,
            'user_id': userId,
          },
        )
        .toList();
  }

  Map<String, dynamic> _clientToRow(Client client, String userId) {
    return {
      'id': client.id,
      'user_id': userId,
      'name': client.name,
      'type': client.type,
      'contact_person': client.contactPerson,
      'phone': client.phone,
      'email': client.email,
      'telegram': client.telegram,
      'planned_budget': client.plannedBudget,
      'is_archived': client.isArchived,
      'created_at': client.createdAt.toIso8601String(),
      'updated_at': client.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _retainerToRow(Client client, String userId) {
    final settings = client.retainerSettings;
    if (settings == null) {
      throw StateError('Retainer settings missing for client ${client.id}');
    }
    return {
      'client_id': client.id,
      'user_id': userId,
      'amount': settings.amount,
      'frequency': settings.frequency,
      'next_payment_date': _formatDate(settings.nextPaymentDate),
      'is_enabled': settings.isEnabled,
      'updated_at': settings.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _projectToRow(Project project, String userId) {
    return {
      'id': project.id,
      'user_id': userId,
      'client_id': project.clientId,
      'title': project.title,
      'amount': project.amount,
      'status': project.status,
      'deadline_date':
          project.deadlineDate == null ? null : _formatDate(project.deadlineDate!),
      'is_archived': project.isArchived,
      'created_at': project.createdAt.toIso8601String(),
      'updated_at': project.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _projectInsertPayload(Project project, String userId) {
    return {
      'id': project.id,
      'user_id': userId,
      'client_id': project.clientId,
      'title': project.title,
      'amount': project.amount,
      'status': project.status,
      'deadline_date':
          project.deadlineDate == null ? null : _formatDate(project.deadlineDate!),
      'is_archived': project.isArchived,
    };
  }

  Map<String, dynamic> _paymentToRow(ProjectPayment payment, String userId) {
    return {
      'id': payment.id,
      'user_id': userId,
      'project_id': payment.projectId,
      'amount': payment.amount,
      'kind': payment.kind,
      'status': payment.status,
      'due_date': payment.dueDate == null ? null : _formatDate(payment.dueDate!),
      'paid_date': payment.paidDate == null ? null : _formatDate(payment.paidDate!),
      'created_at': payment.createdAt.toIso8601String(),
      'updated_at': payment.updatedAt.toIso8601String(),
    };
  }

  Client _clientFromRow(
    Map<String, dynamic> row,
    Map<String, dynamic>? retainerRow,
  ) {
    final type = row['type'] as String? ?? 'project';
    final retainer = retainerRow == null
        ? null
        : RetainerSettings(
            amount: (retainerRow['amount'] as num?)?.toDouble() ?? 0,
            frequency: retainerRow['frequency'] as String? ?? 'once_month',
            nextPaymentDate:
                DateTime.tryParse(retainerRow['next_payment_date']?.toString() ?? '')
                    ?? DateTime.now(),
            isEnabled: retainerRow['is_enabled'] as bool? ?? true,
            updatedAt: DateTime.tryParse(retainerRow['updated_at']?.toString() ?? '')
                ?? DateTime.now(),
          );
    return Client(
      id: row['id'] as String? ?? '',
      name: row['name'] as String? ?? '',
      type: type,
      contactPerson: row['contact_person'] as String?,
      phone: row['phone'] as String?,
      email: row['email'] as String?,
      telegram: row['telegram'] as String?,
      plannedBudget: (row['planned_budget'] as num?)?.toDouble(),
      isArchived: row['is_archived'] as bool? ?? false,
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      retainerSettings: type == 'retainer' ? retainer : null,
    );
  }

  Project _projectFromRow(Map<String, dynamic> row) {
    return Project(
      id: row['id'] as String? ?? '',
      clientId: row['client_id'] as String? ?? '',
      title: row['title'] as String? ?? '',
      amount: (row['amount'] as num?)?.toDouble() ?? 0,
      status: row['status'] as String? ?? '',
      isArchived: row['is_archived'] as bool? ?? false,
      deadlineDate: row['deadline_date'] == null
          ? null
          : DateTime.tryParse(row['deadline_date']?.toString() ?? ''),
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  ProjectPayment _projectPaymentFromRow(Map<String, dynamic> row) {
    return ProjectPayment(
      id: row['id'] as String? ?? '',
      projectId: row['project_id'] as String? ?? '',
      amount: (row['amount'] as num?)?.toDouble() ?? 0,
      kind: row['kind'] as String? ?? 'other',
      status: row['status'] as String? ?? 'planned',
      dueDate: row['due_date'] == null
          ? null
          : DateTime.tryParse(row['due_date']?.toString() ?? ''),
      paidDate: row['paid_date'] == null
          ? null
          : DateTime.tryParse(row['paid_date']?.toString() ?? ''),
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String _requireUserId() {
    final userId = currentUser?.id;
    if (userId == null) {
      throw const AuthException('No user session available.');
    }
    return userId;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _logPostgrestError({
    required String operation,
    required PostgrestException error,
    required Map<String, dynamic> payload,
  }) {
    debugPrint(
      'Supabase $operation failed. message=${error.message} '
      'code=${error.code} details=${error.details} hint=${error.hint} '
      'payload=$payload',
    );
  }

  void _logUnknownError({
    required String operation,
    required Object error,
    required Map<String, dynamic> payload,
  }) {
    debugPrint('Supabase $operation failed. error=$error payload=$payload');
  }
}
