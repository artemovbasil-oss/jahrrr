import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/client.dart';
import '../models/project.dart';
import '../models/project_payment.dart';
import '../models/retainer_settings.dart';
import '../models/user_profile.dart';
import '../utils/client_color.dart';

enum ImportMode { replace, merge }

class SupabaseRepository {
  SupabaseRepository(this._client);

  final SupabaseClient _client;
  final Random _random = Random();

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
    await _assertClientOwnership(userId, project.clientId);
    final normalizedStatus = normalizeProjectStage(project.status);
    _validateProjectInsert(
      project: project,
      userId: userId,
      normalizedStatus: normalizedStatus,
    );
    final payload =
        _projectToSupabaseRow(project, userId, normalizedStatus: normalizedStatus);
    _logProjectInsertAttempt(
      userId: userId,
      payload: payload,
    );
    final row = await _runSupabase(
      table: 'projects',
      operation: 'insert',
      payload: payload,
      action: () async {
        return _client.from('projects').insert(payload).select().single();
      },
    );
    return _projectFromRow(row as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> fetchClientRows() async {
    final userId = _requireUserId();
    try {
      final clientRows = await _runSupabase(
        table: 'clients',
        operation: 'select',
        payload: {'user_id': userId},
        action: () async {
          return _client
              .from('clients')
              .select()
              .eq('user_id', userId)
              .order('created_at');
        },
      );
      return clientRows
          .map<Map<String, dynamic>>((row) => row as Map<String, dynamic>)
          .toList();
    } on PostgrestException catch (error) {
      if (_supportsAvatarColorColumn && _isAvatarColorMissing(error)) {
        _supportsAvatarColorColumn = false;
        final fallbackRows = await _runSupabase(
          table: 'clients',
          operation: 'select',
          payload: {'user_id': userId, 'fallback': true},
          action: () async {
            return _client
                .from('clients')
                .select(_clientFallbackColumns())
                .eq('user_id', userId)
                .order('created_at');
          },
        );
        return fallbackRows
            .map<Map<String, dynamic>>((row) => row as Map<String, dynamic>)
            .toList();
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchRetainerSettingsRows() async {
    final userId = _requireUserId();
    final retainerRows = await _runSupabase(
      table: 'retainer_settings',
      operation: 'select',
      payload: {'user_id': userId},
      action: () async {
        return _client
            .from('retainer_settings')
            .select()
            .eq('user_id', userId);
      },
    );
    return retainerRows
        .map<Map<String, dynamic>>((row) => row as Map<String, dynamic>)
        .toList();
  }

  List<Client> buildClientsWithRetainers({
    required List<Map<String, dynamic>> clientRows,
    required List<Map<String, dynamic>> retainerRows,
  }) {
    final retainers = <String, Map<String, dynamic>>{
      for (final row in retainerRows) row['client_id'] as String: row,
    };
    return clientRows
        .map<Client>(
          (row) => _clientFromRow(row, retainers[row['id'] as String]),
        )
        .toList();
  }

  Future<List<Project>> fetchProjects() async {
    final userId = _requireUserId();
    final rows = await _runSupabase(
      table: 'projects',
      operation: 'select',
      payload: {'user_id': userId},
      action: () async {
        return _client
            .from('projects')
            .select()
            .eq('user_id', userId)
            .order('created_at');
      },
    );
    return rows
        .map<Project>((row) => _projectFromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProjectPayment>> fetchProjectPayments() async {
    final userId = _requireUserId();
    final rows = await _runSupabase(
      table: 'project_payments',
      operation: 'select',
      payload: {'user_id': userId},
      action: () async {
        return _client
            .from('project_payments')
            .select()
            .eq('user_id', userId)
            .order('created_at');
      },
    );
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
    final clients = await _runSupabase(
      table: 'clients',
      operation: 'select',
      payload: {'user_id': user.id},
      action: () async {
        return _client.from('clients').select().eq('user_id', user.id);
      },
    );
    final retainers = await _runSupabase(
      table: 'retainer_settings',
      operation: 'select',
      payload: {'user_id': user.id},
      action: () async {
        return _client.from('retainer_settings').select().eq('user_id', user.id);
      },
    );
    final projects = await _runSupabase(
      table: 'projects',
      operation: 'select',
      payload: {'user_id': user.id},
      action: () async {
        return _client.from('projects').select().eq('user_id', user.id);
      },
    );
    final payments = await _runSupabase(
      table: 'project_payments',
      operation: 'select',
      payload: {'user_id': user.id},
      action: () async {
        return _client.from('project_payments').select().eq('user_id', user.id);
      },
    );

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
    final clients = _sanitizeClientImportList(data['clients'], userId);
    final retainers = _sanitizeImportList(data['retainer_settings'], userId);
    final projects = _sanitizeImportList(data['projects'], userId)
        .map((row) => _projectImportPayload(row, userId))
        .toList();
    final payments = _sanitizeImportList(data['project_payments'], userId);

    if (mode == ImportMode.replace) {
      await _runSupabase(
        table: 'project_payments',
        operation: 'delete',
        payload: {'user_id': userId},
        action: () async {
          return _client.from('project_payments').delete().eq('user_id', userId);
        },
      );
      await _runSupabase(
        table: 'projects',
        operation: 'delete',
        payload: {'user_id': userId},
        action: () async {
          return _client.from('projects').delete().eq('user_id', userId);
        },
      );
      await _runSupabase(
        table: 'retainer_settings',
        operation: 'delete',
        payload: {'user_id': userId},
        action: () async {
          return _client.from('retainer_settings').delete().eq('user_id', userId);
        },
      );
      await _runSupabase(
        table: 'clients',
        operation: 'delete',
        payload: {'user_id': userId},
        action: () async {
          return _client.from('clients').delete().eq('user_id', userId);
        },
      );
    }

    final clientPayload = _supportsAvatarColorColumn
        ? clients
        : _stripAvatarColorFromRows(clients);
    if (clientPayload.isNotEmpty) {
      try {
        await _runSupabase(
          table: 'clients',
          operation: 'upsert',
          payload: {'rows': clientPayload.length},
          action: () async {
            return _client.from('clients').upsert(clientPayload);
          },
        );
      } on PostgrestException catch (error) {
        if (_supportsAvatarColorColumn && _isAvatarColorMissing(error)) {
          _supportsAvatarColorColumn = false;
          final fallbackClients = _stripAvatarColorFromRows(clients);
          if (fallbackClients.isNotEmpty) {
            await _runSupabase(
              table: 'clients',
              operation: 'upsert',
              payload: {'rows': fallbackClients.length, 'fallback': true},
              action: () async {
                return _client.from('clients').upsert(fallbackClients);
              },
            );
          }
        } else {
          rethrow;
        }
      }
    }
    if (retainers.isNotEmpty) {
      await _runSupabase(
        table: 'retainer_settings',
        operation: 'upsert',
        payload: {'rows': retainers.length},
        action: () async {
          return _client.from('retainer_settings').upsert(retainers);
        },
      );
    }
    if (projects.isNotEmpty) {
      await _runSupabase(
        table: 'projects',
        operation: 'upsert',
        payload: {'rows': projects.length},
        action: () async {
          return _client.from('projects').upsert(projects);
        },
      );
    }
    if (payments.isNotEmpty) {
      await _runSupabase(
        table: 'project_payments',
        operation: 'upsert',
        payload: {'rows': payments.length},
        action: () async {
          return _client.from('project_payments').upsert(payments);
        },
      );
    }
  }

  Future<void> _syncClients(String userId, List<Client> clients) async {
    final existing = await _runSupabase(
      table: 'clients',
      operation: 'select',
      payload: {'user_id': userId, 'columns': ['id']},
      action: () async {
        return _client.from('clients').select('id').eq('user_id', userId);
      },
    );
    final existingIds = existing
        .map<String>((row) => row['id'] as String)
        .toSet();
    final currentIds = clients.map((client) => client.id).toSet();
    final toDelete = existingIds.difference(currentIds).toList();
    if (toDelete.isNotEmpty) {
      await _runSupabase(
        table: 'clients',
        operation: 'delete',
        payload: {'id_count': toDelete.length},
        action: () async {
          return _client.from('clients').delete().inFilter('id', toDelete);
        },
      );
    }
    final payload = clients
        .map((client) => _clientToRow(client, userId))
        .toList();
    if (payload.isNotEmpty) {
      try {
        await _runSupabase(
          table: 'clients',
          operation: 'upsert',
          payload: {'rows': payload.length},
          action: () async {
            return _client.from('clients').upsert(payload);
          },
        );
      } on PostgrestException catch (error) {
        if (_supportsAvatarColorColumn && _isAvatarColorMissing(error)) {
          _supportsAvatarColorColumn = false;
          final fallbackPayload = clients
              .map((client) => _clientToRow(client, userId))
              .toList();
          if (fallbackPayload.isNotEmpty) {
            await _runSupabase(
              table: 'clients',
              operation: 'upsert',
              payload: {'rows': fallbackPayload.length, 'fallback': true},
              action: () async {
                return _client.from('clients').upsert(fallbackPayload);
              },
            );
          }
        } else {
          rethrow;
        }
      }
    }

    final retainerExisting = await _runSupabase(
      table: 'retainer_settings',
      operation: 'select',
      payload: {'user_id': userId, 'columns': ['client_id']},
      action: () async {
        return _client
            .from('retainer_settings')
            .select('client_id')
            .eq('user_id', userId);
      },
    );
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
      await _runSupabase(
        table: 'retainer_settings',
        operation: 'delete',
        payload: {'client_id_count': retainerDelete.length},
        action: () async {
          return _client.from('retainer_settings').delete().inFilter(
                'client_id',
                retainerDelete,
              );
        },
      );
    }
    if (retainerPayload.isNotEmpty) {
      await _runSupabase(
        table: 'retainer_settings',
        operation: 'upsert',
        payload: {'rows': retainerPayload.length},
        action: () async {
          return _client.from('retainer_settings').upsert(retainerPayload);
        },
      );
    }
  }

  Future<void> _syncProjects(String userId, List<Project> projects) async {
    final existing = await _runSupabase(
      table: 'projects',
      operation: 'select',
      payload: {'user_id': userId, 'columns': ['id']},
      action: () async {
        return _client.from('projects').select('id').eq('user_id', userId);
      },
    );
    final existingIds = existing
        .map<String>((row) => row['id'] as String)
        .toSet();
    final currentIds = projects.map((project) => project.id).toSet();
    final toDelete = existingIds.difference(currentIds).toList();
    if (toDelete.isNotEmpty) {
      await _runSupabase(
        table: 'projects',
        operation: 'delete',
        payload: {'id_count': toDelete.length},
        action: () async {
          return _client.from('projects').delete().inFilter('id', toDelete);
        },
      );
    }
    final payload = projects
        .map(
          (project) => _projectToSupabaseRow(
            project,
            userId,
            normalizedStatus: normalizeProjectStage(project.status),
            includeTimestamps: true,
          ),
        )
        .toList();
    if (payload.isNotEmpty) {
      await _runSupabase(
        table: 'projects',
        operation: 'upsert',
        payload: {'rows': payload.length},
        action: () async {
          return _client.from('projects').upsert(payload);
        },
      );
    }
  }

  Future<void> _syncPayments(
    String userId,
    List<ProjectPayment> payments,
  ) async {
    final existing = await _runSupabase(
      table: 'project_payments',
      operation: 'select',
      payload: {'user_id': userId, 'columns': ['id']},
      action: () async {
        return _client
            .from('project_payments')
            .select('id')
            .eq('user_id', userId);
      },
    );
    final existingIds = existing
        .map<String>((row) => row['id'] as String)
        .toSet();
    final currentIds = payments.map((payment) => payment.id).toSet();
    final toDelete = existingIds.difference(currentIds).toList();
    if (toDelete.isNotEmpty) {
      await _runSupabase(
        table: 'project_payments',
        operation: 'delete',
        payload: {'id_count': toDelete.length},
        action: () async {
          return _client
              .from('project_payments')
              .delete()
              .inFilter('id', toDelete);
        },
      );
    }
    final payload = payments
        .map((payment) => _paymentToRow(payment, userId))
        .toList();
    if (payload.isNotEmpty) {
      await _runSupabase(
        table: 'project_payments',
        operation: 'upsert',
        payload: {'rows': payload.length},
        action: () async {
          return _client.from('project_payments').upsert(payload);
        },
      );
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

  List<Map<String, dynamic>> _sanitizeClientImportList(dynamic raw, String userId) {
    if (raw is! List) {
      return [];
    }
    return raw.whereType<Map<String, dynamic>>().map((row) {
      final storedColor = (row['color'] ?? row['avatar_color']) as String?;
      final normalizedColor = storedColor != null && storedColor.isNotEmpty
          ? storedColor
          : generateClientColorHex(_random);
      return {
        ...row,
        'user_id': userId,
        'color': normalizedColor,
        'avatar_color': normalizedColor,
      };
    }).toList();
  }

  Map<String, dynamic> _clientToRow(Client client, String userId) {
    final payload = {
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
      'color': client.avatarColorHex,
      'avatar_color': client.avatarColorHex,
      'created_at': client.createdAt.toIso8601String(),
      'updated_at': client.updatedAt.toIso8601String(),
    };
    if (_supportsAvatarColorColumn) {
      payload['avatar_color'] = client.avatarColorHex;
    }
    return payload;
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

  Map<String, dynamic> _projectToSupabaseRow(
    Project project,
    String userId, {
    required String? normalizedStatus,
    bool includeTimestamps = false,
  }) {
    final payload = <String, dynamic>{
      'id': project.id,
      'user_id': userId,
      'client_id': project.clientId,
      'title': project.title,
      'amount': project.amount,
      'status': normalizedStatus ?? project.status,
      'deadline_date': project.deadlineDate == null
          ? null
          : _formatDate(project.deadlineDate!),
    };
    if (includeTimestamps) {
      payload['created_at'] = project.createdAt.toIso8601String();
      payload['updated_at'] = project.updatedAt.toIso8601String();
    }
    return payload;
  }

  Map<String, dynamic> _projectImportPayload(
    Map<String, dynamic> row,
    String userId,
  ) {
    final payload = <String, dynamic>{
      'user_id': userId,
      'client_id': row['client_id'],
      'title': row['title'],
      'amount': row['amount'],
      'status': row['status'],
      'deadline_date': row['deadline_date'],
    };
    if (row['id'] != null) {
      payload['id'] = row['id'];
    }
    if (row['created_at'] != null) {
      payload['created_at'] = row['created_at'];
    }
    if (row['updated_at'] != null) {
      payload['updated_at'] = row['updated_at'];
    }
    return payload;
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
      avatarColorHex:
          row['color'] as String? ?? row['avatar_color'] as String? ?? '',
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
    final userId =
        currentUser?.id ?? _client.auth.currentSession?.user.id;
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

  String _clientFallbackColumns() {
    return 'id,user_id,name,type,contact_person,phone,email,telegram,planned_budget,'
        'created_at,updated_at';
  }

  bool _isAvatarColorMissing(PostgrestException error) {
    return error.code == 'PGRST204' &&
        error.message.toLowerCase().contains('avatar_color');
  }

  List<Map<String, dynamic>> _stripAvatarColorFromRows(
    List<Map<String, dynamic>> rows,
  ) {
    return rows
        .map(
          (row) => {
            for (final entry in row.entries)
              if (entry.key != 'avatar_color') entry.key: entry.value,
          },
        )
        .toList();
  }

  Future<T> _runSupabase<T>({
    required String table,
    required String operation,
    required Future<T> Function() action,
    Map<String, dynamic> payload = const {},
  }) async {
    try {
      return await action();
    } on PostgrestException catch (error) {
      _logPostgrestError(
        table: table,
        operation: operation,
        error: error,
        payload: payload,
      );
      rethrow;
    } catch (error) {
      _logUnknownError(
        table: table,
        operation: operation,
        error: error,
        payload: payload,
      );
      rethrow;
    }
  }

  void _logPostgrestError({
    required String table,
    required String operation,
    required PostgrestException error,
    required Map<String, dynamic> payload,
  }) {
    debugPrint(
      'Supabase $table $operation failed. message=${error.message} '
      'code=${error.code} details=${error.details} hint=${error.hint} '
      'user_id=${currentUser?.id} session=${_client.auth.currentSession != null} '
      'payload_keys=${payload.keys.toList()}',
    );
  }

  void _logUnknownError({
    required String table,
    required String operation,
    required Object error,
    required Map<String, dynamic> payload,
  }) {
    debugPrint(
      'Supabase $table $operation failed. error=$error '
      'user_id=${currentUser?.id} session=${_client.auth.currentSession != null} '
      'payload_keys=${payload.keys.toList()}',
    );
  }

  void _logProjectInsertAttempt({
    required String userId,
    required Map<String, dynamic> payload,
  }) {
    debugPrint(
      'Supabase projects.insert attempt user_id=$userId '
      'payload_keys=${payload.keys.toList()}',
    );
  }

  void _validateProjectInsert({
    required Project project,
    required String userId,
    required String? normalizedStatus,
  }) {
    if (userId.trim().isEmpty) {
      throw const AuthException('Missing authenticated user id.');
    }
    if (!_isValidUuid(project.clientId)) {
      throw ArgumentError.value(
        project.clientId,
        'client_id',
        'Client id must be a valid UUID.',
      );
    }
    if (project.title.trim().isEmpty) {
      throw ArgumentError('Project title cannot be empty.');
    }
    if (project.amount <= 0) {
      throw ArgumentError.value(
        project.amount,
        'amount',
        'Project amount must be greater than 0.',
      );
    }
    if (normalizedStatus == null) {
      throw ArgumentError.value(
        project.status,
        'status',
        'Project status must match a supported stage.',
      );
    }
  }

  bool _isValidUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-'
      r'[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(value);
  }

  Future<void> _assertClientOwnership(String userId, String clientId) async {
    final row = await _runSupabase(
      table: 'clients',
      operation: 'select',
      payload: {'id': clientId, 'user_id': userId, 'columns': ['id']},
      action: () async {
        return _client
            .from('clients')
            .select('id')
            .eq('id', clientId)
            .eq('user_id', userId)
            .maybeSingle();
      },
    );
    if (row == null) {
      throw StateError(
        'Selected client does not exist for the current user.',
      );
    }
  }

  Future<String?> fetchFirstEligibleClientId() async {
    final userId = _requireUserId();
    final row = await _runSupabase(
      table: 'clients',
      operation: 'select',
      payload: {'user_id': userId, 'columns': ['id']},
      action: () async {
        return _client
            .from('clients')
            .select('id')
            .eq('user_id', userId)
            .neq('type', 'retainer')
            .order('created_at')
            .limit(1)
            .maybeSingle();
      },
    );
    return row == null ? null : row['id'] as String?;
  }
}
