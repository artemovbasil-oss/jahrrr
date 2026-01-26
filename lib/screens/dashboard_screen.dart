import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../controllers/sync_status_controller.dart';
import '../models/client.dart';
import '../models/project.dart';
import '../models/project_payment.dart';
import '../models/retainer_settings.dart';
import '../models/user_profile.dart';
import '../services/supabase_repository.dart';
import '../utils/client_color.dart';
import '../utils/color_contrast.dart';
import '../utils/operation_feedback.dart';
import '../widgets/client_color_picker.dart';
import '../widgets/milestone_project_card.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton.dart';
import '../widgets/stat_card.dart';
import '../widgets/user_avatar.dart';
import 'client_detail_screen.dart';
import 'milestones_deadlines_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.repository,
    required this.onLoggedOut,
  });

  final SupabaseRepository repository;
  final VoidCallback onLoggedOut;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _AvatarColorUpdate {
  const _AvatarColorUpdate({
    required this.clients,
    required this.updated,
  });

  final List<Client> clients;
  final bool updated;
}

class _BootstrapFailure implements Exception {
  const _BootstrapFailure({
    required this.source,
    required this.error,
  });

  final String source;
  final Object error;
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Map<String, String> _paymentKindLabels = {
    'deposit': 'Deposit',
    'milestone': 'Milestone',
    'final': 'Final payment',
    'other': 'Other',
  };
  static const Map<String, String> _retainerFrequencyLabels = {
    'once_month': 'Once a month',
    'twice_month': 'Twice a month',
  };

  String? _selectedClientStatus;
  String? _selectedContractType;
  final GlobalKey<FormState> _clientFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _projectFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _paymentFormKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _plannedBudgetController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactTelegramController = TextEditingController();
  final TextEditingController _clientNotesController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectAmountController = TextEditingController();
  final TextEditingController _paymentAmountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedProjectClient;
  String? _selectedProjectStage;
  String? _selectedRetainerFrequency;
  DateTime? _selectedProjectDeadline;
  DateTime? _selectedRetainerPayDate;
  String? _selectedPaymentProjectId;
  String? _selectedPaymentKind;
  DateTime? _selectedPaymentDueDate;
  DateTime? _selectedPaymentPaidDate;
  String? _selectedPaymentStatus;
  late final ScrollController _scrollController;
  bool _showMascot = false;
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  _BootstrapFailure? _bootstrapFailure;
  UserProfile? _profile;
  late final SupabaseRepository _repository;
  late final SyncStatusController _syncStatusController;
  String _selectedClientColorHex = defaultClientColorHex();
  bool _showClientColorError = false;

  final List<Client> _clients = [];
  final List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository;
    _syncStatusController = SyncStatusController();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _loadProfile();
    _bootstrapData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _clientNameController.dispose();
    _plannedBudgetController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _contactTelegramController.dispose();
    _clientNotesController.dispose();
    _projectNameController.dispose();
    _projectAmountController.dispose();
    _paymentAmountController.dispose();
    _searchController.dispose();
    _syncStatusController.dispose();
    super.dispose();
  }

  final List<ProjectPayment> _projectPayments = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = _normalizeDate(now);
    final range7End = today.add(const Duration(days: 6));
    final upcomingWindowEnd = today.add(const Duration(days: 7));
    final range30End = today.add(const Duration(days: 29));
    final activeProjects =
        _isLoading ? const <Project>[] : _activeProjects();
    final milestoneProjects = _isLoading
        ? const <Project>[]
        : _sortedMilestoneProjects(activeProjects);
    final activeProjectsCount = activeProjects.length;
    final activeProjectClientsCount = _isLoading
        ? 0
        : _activeProjectClients(activeProjects).length;
    final retainerNext30 =
        _isLoading ? 0.0 : _retainerScheduledSum(today, range30End);
    final projectBudgetSum = _isLoading ? 0.0 : _projectBudgetSum();
    final budgetInProgress = retainerNext30 + projectBudgetSum;
    final deadlinesThisWeek =
        _isLoading ? 0 : _deadlineProjects(today, range7End).length;
    final upcomingPaymentEntries =
        _isLoading ? const <_UpcomingPaymentEntry>[] : _buildUpcomingPayments(today, upcomingWindowEnd);
    final upcomingPayments = _isLoading
        ? 0.0
        : upcomingPaymentEntries.fold<double>(0, (sum, entry) => sum + entry.amount);
    final clientStatuses = projectStageLabels.entries.toList();
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filteredMilestoneProjects = normalizedQuery.isEmpty
        ? milestoneProjects
        : milestoneProjects
            .where(
              (project) =>
                  project.title.toLowerCase().contains(normalizedQuery) ||
                  _clientNameForId(project.clientId)
                      .toLowerCase()
                      .contains(normalizedQuery),
            )
            .toList();
    final limitedMilestoneProjects = filteredMilestoneProjects.take(5).toList();
    final showMilestonesViewAll = filteredMilestoneProjects.length > 5;
    final visibleClients = _selectedClientStatus == null
        ? _visibleClients()
        : _visibleClients()
            .where(
              (client) => _projects.any(
                (project) =>
                    project.clientId == client.id &&
                    project.status == _selectedClientStatus,
              ),
            )
            .toList();
    final filteredClients = normalizedQuery.isEmpty
        ? visibleClients
        : visibleClients
            .where(
              (client) =>
                  client.name.toLowerCase().contains(normalizedQuery) ||
                  (client.contactPerson ?? '').toLowerCase().contains(normalizedQuery),
            )
            .toList();
    final upcomingPaymentItems = _isLoading
        ? const <_PaymentPillItem>[]
        : _paymentPillItemsFromEntries(upcomingPaymentEntries);
    final selectedChipColor = theme.colorScheme.primaryContainer;
    final selectedChipLabelColor = contrastColorFor(selectedChipColor);
    final filteredPayments = normalizedQuery.isEmpty
        ? upcomingPaymentItems
        : upcomingPaymentItems
            .where(
              (payment) =>
                  payment.clientName.toLowerCase().contains(normalizedQuery) ||
                  payment.tagLabel.toLowerCase().contains(normalizedQuery),
            )
            .toList();
    final milestoneWidgets = filteredMilestoneProjects.isEmpty
        ? [_buildEmptyState('Add a project to track milestones.')]
        : limitedMilestoneProjects
            .map(
              (project) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MilestoneProjectCard(
                  project: project,
                  clientName: _clientNameForId(project.clientId),
                  amountLabel: _formatCurrency(project.amount),
                  progressValue: _projectStageProgress(project.status),
                  progressColor: _projectStageColor(project.status),
                  onTap: () {
                    final client = _clientById(project.clientId);
                    if (client == null) {
                      return;
                    }
                    _openClientDetails(client);
                  },
                ),
              ),
            )
            .toList();
    final paymentWidgets = _isLoading
        ? _buildLoadingPaymentPills()
        : filteredPayments.isEmpty
            ? [_buildEmptyState('No payments this week.')]
            : [
                ...filteredPayments.map(
                  (payment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PaymentPill(
                      item: payment,
                      formattedAmount: _formatCurrency(payment.amount),
                      formattedDate: _formatDate(payment.date),
                      avatarColor: _paymentPillColor(context, payment),
                      onTap: () {
                        if (payment.type == _PaymentPillType.project) {
                          final project = _projectById(payment.projectId ?? '');
                          if (project == null) {
                            return;
                          }
                          final client = _clientById(project.clientId);
                          if (client == null) {
                            return;
                          }
                          _openClientDetails(client);
                        } else {
                          final client = _clientById(payment.clientId);
                          if (client == null) {
                            return;
                          }
                          _openClientDetails(client);
                        }
                      },
                    ),
                  ),
                ),
              ];
    final clientWidgets = _isLoading
        ? _buildLoadingClientCards()
        : filteredClients.isEmpty
                ? [_buildEmptyState('Add a client to get started.')]
                : filteredClients
                    .map(
                      (client) => _ClientCard(
                        client: client,
                        isRetainer: _isRetainerClient(client),
                        initials: _clientInitials(client.name),
                        typeLabel: _clientTypeLabel(client),
                        formattedAmount: _formatCurrency(_clientTotalAmount(client)),
                        cardColor: _clientCardColor(context, client),
                        tagColor: _clientTagColor(client),
                        avatarColor: _clientAvatarColor(client),
                        onTap: () => _openClientDetails(client),
                      ),
                    )
                    .toList();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _openProfile,
            child: UserAvatar(
              name: _profile?.name,
              email: _profile?.email,
            ),
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search clients, projects, or payments',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi ${_profile?.displayName ?? 'there'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  _buildSyncStatusIndicator(),
                ],
              ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          if (kDebugMode)
            IconButton(
              tooltip: 'Debug insert project',
              onPressed: _debugInsertProject,
              icon: const Icon(Icons.bug_report_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          if (_bootstrapFailure != null) ...[
            _buildBootstrapErrorBanner(),
            const SizedBox(height: 16),
          ],
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.95,
            children: _isLoading
                ? List.generate(4, (_) => _buildSkeletonStatCard(context))
                : [
                    StatCard(
                      title: 'Active projects',
                      value: activeProjectsCount.toString(),
                      tag: '$activeProjectClientsCount active clients',
                      accentColor: const Color(0xFF0369A1),
                      gradient: const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                      onTap: () => _showActiveProjectsSheet(activeProjects),
                    ),
                    StatCard(
                      title: 'Budget in progress',
                      value: _formatCurrency(budgetInProgress),
                      tag: '$activeProjectsCount projects',
                      accentColor: const Color(0xFF00A63E),
                      gradient: const [Color(0xFFF0F5E0), Color(0xFF96CA49)],
                      onTap: () => _showBudgetBreakdownSheet(
                        today,
                        range30End,
                      ),
                    ),
                    StatCard(
                      title: 'Deadlines',
                      value: deadlinesThisWeek.toString(),
                      tag: 'This week',
                      accentColor: const Color(0xFFCA8A04),
                      gradient: const [Color(0xFFFEF3C7), Color(0xFFFDE047)],
                      onTap: () => _showDeadlinesSheet(
                        _deadlineProjects(today, range7End),
                      ),
                    ),
                    StatCard(
                      title: 'Upcoming payments',
                      value: _formatCurrency(upcomingPayments),
                      tag: 'This week',
                      accentColor: const Color(0xFF0F0E0E),
                      gradient: const [Colors.white, Color(0xFFC0C0C0)],
                      onTap: () =>
                          _showUpcomingPaymentsSheet(today, upcomingWindowEnd),
                    ),
                  ],
          ),
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Milestones & deadlines',
            actionLabel: showMilestonesViewAll ? 'View all' : null,
            onActionPressed: showMilestonesViewAll
                ? () => _openMilestonesDeadlines(milestoneProjects)
                : null,
          ),
          const SizedBox(height: 12),
          ...(_isLoading ? _buildLoadingMilestones() : milestoneWidgets),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Upcoming payments',
            actionLabel: 'Add',
            onActionPressed: () {
              final hasProjects = _projects.any(
                (project) => _clientById(project.clientId) != null,
              );
              if (!hasProjects) {
                _showSnackBar(context, 'Create a project first');
                return;
              }
              _showPaymentForm();
            },
          ),
          const SizedBox(height: 12),
          ...paymentWidgets,
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Clients',
            actionLabel: 'Add',
            onActionPressed: _showClientForm,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedClientStatus == null,
                  onSelected: (_) => _updateClientStatusFilter(null),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  selectedColor: selectedChipColor,
                  checkmarkColor: selectedChipLabelColor,
                  labelStyle: TextStyle(
                    color: _selectedClientStatus == null
                        ? selectedChipLabelColor
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                ...clientStatuses.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status.value),
                      selected: _selectedClientStatus == status.key,
                      onSelected: (_) => _updateClientStatusFilter(status.key),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      selectedColor: selectedChipColor,
                      checkmarkColor: selectedChipLabelColor,
                      labelStyle: TextStyle(
                        color: _selectedClientStatus == status.key
                            ? selectedChipLabelColor
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...clientWidgets,
          const SizedBox(height: 12),
          _buildMascotReveal(),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Just +',
        onPressed: _showQuickAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showQuickAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person_add_outlined),
                  title: const Text('Add client'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showClientForm();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: const Text('Add project'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openProjectFormFromMenu();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Add payment'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openPaymentFormFromMenu();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  Future<void> _loadProfile() async {
    final profile = _repository.currentUserProfile();
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = profile;
    });
  }

  Future<void> _openProfile() async {
    final result = await Navigator.of(context).push<ProfileResult>(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          profile: _profile,
          repository: _repository,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == ProfileResult.updated || result == ProfileResult.dataImported) {
      await _loadProfile();
      if (result == ProfileResult.dataImported) {
        await _bootstrapData();
      }
    } else if (result == ProfileResult.loggedOut) {
      widget.onLoggedOut();
    }
  }

  Future<bool> _bootstrapData() async {
    if (!mounted) {
      return false;
    }
    _syncStatusController.setLoading();
    setState(() {
      _isLoading = true;
      _bootstrapFailure = null;
    });

    var success = false;
    final auth = Supabase.instance.client.auth;
    final session = auth.currentSession;
    if (session == null) {
      _handleBootstrapFailure(
        const _BootstrapFailure(
          source: 'auth.session',
          error: AuthException('No active session available.'),
        ),
      );
      widget.onLoggedOut();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return false;
    }

    if (auth.currentUser == null) {
      try {
        await auth.getUser();
      } catch (error) {
        _logBootstrapFailure(
          _BootstrapFailure(source: 'auth.getUser', error: error),
        );
      }
    }

    try {
      final clientRowsFuture =
          _wrapBootstrapCall('clients.select', _repository.fetchClientRows);
      final retainerRowsFuture = _wrapBootstrapCall(
        'retainer_settings.select',
        _repository.fetchRetainerSettingsRows,
      );
      final projectsFuture =
          _wrapBootstrapCall('projects.select', _repository.fetchProjects);
      final paymentsFuture = _wrapBootstrapCall(
        'project_payments.select',
        _repository.fetchProjectPayments,
      );

      final clientRows = await clientRowsFuture;
      final retainerRows = await retainerRowsFuture;
      final projects = await projectsFuture;
      final payments = await paymentsFuture;
      final existingAvatarColors = {
        for (final client in _clients) client.id: client.avatarColorHex,
      };
      final clients = _repository.buildClientsWithRetainers(
        clientRows: clientRows,
        retainerRows: retainerRows,
        existingAvatarColors: existingAvatarColors,
      );
      final ensuredClients = _ensureClientAvatarColors(clients);
      Client? nonDefaultClient;
      for (final client in ensuredClients.clients) {
        if (client.avatarColorHex != defaultClientColorHex()) {
          nonDefaultClient = client;
          break;
        }
      }
      if (nonDefaultClient != null) {
        debugPrint(
          'Client color loaded (bootstrap): client=${nonDefaultClient.id} '
          'avatar_color=${nonDefaultClient.avatarColorHex}',
        );
        debugPrint(
          'Client color regression check (bootstrap): client=${nonDefaultClient.id} '
          'avatar_color=${nonDefaultClient.avatarColorHex}',
        );
      } else {
        debugPrint(
          'Client color loaded (bootstrap): no non-default avatar colors found.',
        );
        debugPrint(
          'Client color regression check (bootstrap): no non-default avatar colors found.',
        );
      }
      debugPrint(
        'Client color sync (bootstrap): clients=${ensuredClients.clients.length}',
      );
      if (ensuredClients.updated) {
        await _repository.syncAll(
          clients: ensuredClients.clients,
          projects: projects,
          payments: payments,
        );
      }
      if (!mounted) {
        return false;
      }
      setState(() {
        _clients
          ..clear()
          ..addAll(ensuredClients.clients);
        _projects
          ..clear()
          ..addAll(projects);
        _projectPayments
          ..clear()
          ..addAll(payments);
      });
      _syncStatusController.setSynced();
      success = true;
    } on _BootstrapFailure catch (failure) {
      _handleBootstrapFailure(failure);
      success = false;
    } catch (error) {
      _handleBootstrapFailure(_BootstrapFailure(source: 'bootstrap', error: error));
      success = false;
    } finally {
      if (!mounted) {
        return false;
      }
      setState(() {
        _isLoading = false;
      });
    }
    return success;
  }

  Future<T> _wrapBootstrapCall<T>(
    String source,
    Future<T> Function() call,
  ) async {
    try {
      return await call();
    } catch (error) {
      throw _BootstrapFailure(source: source, error: error);
    }
  }

  void _handleBootstrapFailure(_BootstrapFailure failure) {
    _logBootstrapFailure(failure);
    if (!mounted) {
      return;
    }
    setState(() {
      _bootstrapFailure = failure;
      _clients.clear();
      _projects.clear();
      _projectPayments.clear();
    });
    _syncStatusController.setFailed();
    _showSnackBar(context, 'Failed to sync data.');
  }

  void _logBootstrapFailure(_BootstrapFailure failure) {
    final auth = Supabase.instance.client.auth;
    final session = auth.currentSession;
    final userId = auth.currentUser?.id ?? session?.user.id;
    final error = failure.error;
    if (error is PostgrestException) {
      debugPrint(
        'Bootstrap failed source=${failure.source} message=${error.message} '
        'code=${error.code} details=${error.details} hint=${error.hint} '
        'user_id=$userId session=${session != null}',
      );
    } else {
      debugPrint(
        'Bootstrap failed source=${failure.source} error=$error '
        'user_id=$userId session=${session != null}',
      );
    }
  }

  String _bootstrapFailureMessage(_BootstrapFailure failure) {
    final error = failure.error;
    if (error is PostgrestException) {
      final detailParts = [
        'message=${error.message}',
        if (error.code != null) 'code=${error.code}',
        if (error.details != null) 'details=${error.details}',
        if (error.hint != null) 'hint=${error.hint}',
      ].join(', ');
      return 'Supabase ${failure.source} failed: $detailParts';
    }
    if (error is AuthException) {
      return 'Auth error during ${failure.source}: ${error.message}';
    }
    return 'Bootstrap failed during ${failure.source}: $error';
  }

  Widget _buildBootstrapErrorBanner() {
    final failure = _bootstrapFailure;
    if (failure == null) {
      return const SizedBox.shrink();
    }
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data load failed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _bootstrapFailureMessage(failure),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _bootstrapData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _persistData() async {
    try {
      _syncStatusController.setLoading();
      await _repository.syncAll(
        clients: _clients,
        projects: _projects,
        payments: _projectPayments,
      );
      final refreshed = await _bootstrapData();
      if (!refreshed) {
        return false;
      }
      _syncStatusController.setSynced();
      return true;
    } catch (_) {
      _syncStatusController.setFailed();
      return false;
    }
  }

  Widget _buildSyncStatusIndicator() {
    return AnimatedBuilder(
      animation: _syncStatusController,
      builder: (context, _) {
        final isLoading = _syncStatusController.isLoading;
        final isFailed = _syncStatusController.isFailed;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final label = isLoading
            ? 'Syncing…'
            : isFailed
                ? 'Sync failed'
                : 'Up to date';
        final color = isLoading
            ? const Color(0xFFFFC107)
            : isFailed
                ? const Color(0xFFD32F2F)
                : const Color(0xFF2E7D32);
        final textColor = theme.colorScheme.onSurfaceVariant
            .withOpacity(isDark ? 0.82 : 0.72);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    final shouldShow = position.pixels >= position.maxScrollExtent - 40;
    if (shouldShow != _showMascot) {
      setState(() {
        _showMascot = shouldShow;
      });
    }
  }

  Widget _buildMascotReveal() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      child: _showMascot
          ? Container(
              key: const ValueKey('mascot'),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '🐙',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Jahrrr! You made it to the end.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(key: ValueKey('mascot-empty')),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _buildSkeletonStatCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 14, width: 110),
          SizedBox(height: 16),
          SkeletonBox(height: 28, width: 90),
          SizedBox(height: 12),
          SkeletonBox(height: 12, width: 140),
        ],
      ),
    );
  }

  List<Widget> _buildLoadingMilestones() {
    return List.generate(
      3,
      (_) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 16, width: 160),
            SizedBox(height: 8),
            SkeletonBox(height: 12, width: 120),
            SizedBox(height: 12),
            SkeletonBox(height: 20, width: 80),
            SizedBox(height: 12),
            SkeletonBox(height: 10, width: double.infinity),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLoadingPaymentPills() {
    return List.generate(
      3,
      (_) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          children: [
            SkeletonBox(height: 40, width: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 14, width: 140),
                  SizedBox(height: 8),
                  SkeletonBox(height: 12, width: 80),
                ],
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonBox(height: 16, width: 70),
                SizedBox(height: 8),
                SkeletonBox(height: 12, width: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLoadingClientCards() {
    return List.generate(
      3,
      (_) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          children: [
            SkeletonBox(height: 40, width: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 14, width: 140),
                  SizedBox(height: 8),
                  SkeletonBox(height: 12, width: 90),
                ],
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonBox(height: 16, width: 70),
                SizedBox(height: 8),
                SkeletonBox(height: 12, width: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClientForm() {
    _clientNameController.clear();
    _plannedBudgetController.clear();
    _contactNameController.clear();
    _contactPhoneController.clear();
    _contactEmailController.clear();
    _contactTelegramController.clear();
    _clientNotesController.clear();
    _selectedContractType = null;
    _selectedRetainerFrequency = null;
    _selectedRetainerPayDate = null;
    _selectedClientColorHex = defaultClientColorHex();
    _showClientColorError = false;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (routeContext) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;
              return Scaffold(
                appBar: AppBar(
                  title: const Text('New client'),
                ),
                body: SafeArea(
                  child: Form(
                    key: _clientFormKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _clientNameController,
                            decoration: const InputDecoration(
                              labelText: 'Client name',
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter a client name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Contract type',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: const {
                              'project': 'Project',
                              'retainer': 'Retainer',
                            }.entries.map((entry) {
                              return ChoiceChip(
                                label: Text(entry.value),
                                selected: _selectedContractType == entry.key,
                                onSelected: (_) {
                                  setModalState(() {
                                    _selectedContractType = entry.key;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          if (_selectedContractType == null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Select a contract type',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          ClientColorPicker(
                            selectedColorHex: _selectedClientColorHex,
                            showError: _showClientColorError,
                            onColorSelected: (hex) {
                              setModalState(() {
                                _selectedClientColorHex = normalizeClientColorHex(hex);
                                _showClientColorError = false;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _plannedBudgetController,
                            decoration: InputDecoration(
                              labelText: _selectedContractType == 'retainer'
                                  ? 'Retainer amount (\$)'
                                  : 'Planned budget (\$) (optional)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (_selectedContractType == 'retainer') {
                                if (trimmed.isEmpty) {
                                  return 'Enter a retainer amount';
                                }
                                final parsed = double.tryParse(
                                  trimmed.replaceAll(',', '.'),
                                );
                                if (parsed == null || parsed <= 0) {
                                  return 'Enter a valid amount';
                                }
                              } else if (trimmed.isNotEmpty) {
                                final parsed = double.tryParse(
                                  trimmed.replaceAll(',', '.'),
                                );
                                if (parsed == null || parsed < 0) {
                                  return 'Enter a valid budget';
                                }
                              }
                              return null;
                            },
                          ),
                          if (_selectedContractType == 'retainer') ...[
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedRetainerFrequency,
                              decoration: const InputDecoration(
                                labelText: 'Payment frequency',
                              ),
                              items: _retainerFrequencyLabels.entries
                                  .map(
                                    (entry) => DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setModalState(() {
                                  _selectedRetainerFrequency = value;
                                });
                              },
                              validator: (value) {
                                if (_selectedContractType != 'retainer') {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'Select a payment frequency';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Next payment date'),
                              subtitle: Text(
                                _selectedRetainerPayDate == null
                                    ? 'Select a date'
                                    : _formatDate(_selectedRetainerPayDate!),
                              ),
                              trailing: const Icon(Icons.calendar_today_outlined),
                              onTap: () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: routeContext,
                                  initialDate: _selectedRetainerPayDate ?? now,
                                  firstDate: now,
                                  lastDate: DateTime(now.year + 5),
                                );
                                if (picked == null) {
                                  return;
                                }
                                setModalState(() {
                                  _selectedRetainerPayDate = picked;
                                });
                              },
                            ),
                            if (_selectedRetainerPayDate == null)
                              Text(
                                'Select a payment date',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                              ),
                          ],
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contactNameController,
                            decoration: const InputDecoration(
                              labelText: 'Contact person',
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _contactPhoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _contactEmailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _contactTelegramController,
                            decoration: const InputDecoration(
                              labelText: 'Telegram',
                              hintText: '@username',
                            ),
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _clientNotesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                            ),
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _clientNotesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                            ),
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: SafeArea(
                  minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(routeContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final isValid =
                                _clientFormKey.currentState?.validate() ?? false;
                            final hasColor = _selectedClientColorHex.trim().isNotEmpty;
                            if (!hasColor) {
                              setModalState(() {
                                _showClientColorError = true;
                              });
                              return;
                            }
                            if (_selectedContractType == null) {
                              setModalState(() {});
                              return;
                            }
                            if (_selectedContractType == 'retainer' &&
                                _selectedRetainerPayDate == null) {
                              setModalState(() {});
                              return;
                            }
                            if (!isValid) {
                              return;
                            }
                            Navigator.of(routeContext).pop();
                            _addClient();
                          },
                          child: const Text('Add client'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditClientForm(Client client) {
    _clientNameController.text = client.name;
    _contactNameController.text = client.contactPerson ?? '';
    _contactPhoneController.text = client.phone ?? '';
    _contactEmailController.text = client.email ?? '';
    _contactTelegramController.text = client.telegram ?? '';
    _clientNotesController.text = client.notes ?? '';
    _selectedContractType = client.type;
    _selectedRetainerFrequency = client.retainerSettings?.frequency;
    _selectedRetainerPayDate = client.retainerSettings?.nextPaymentDate;
    _selectedClientColorHex = normalizeClientColorHex(client.avatarColorHex);
    _showClientColorError = false;
    _plannedBudgetController.text = _isRetainerClient(client)
        ? (client.retainerSettings?.amount ?? 0).toStringAsFixed(0)
        : (client.plannedBudget?.toStringAsFixed(0) ?? '');

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (routeContext) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;
              final contractLabel = _isRetainerClient(client) ? 'Retainer' : 'Project';
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Edit client'),
                ),
                body: SafeArea(
                  child: Form(
                    key: _clientFormKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _clientNameController,
                            decoration: const InputDecoration(
                              labelText: 'Client name',
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter a client name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Contract type: $contractLabel',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          ClientColorPicker(
                            selectedColorHex: _selectedClientColorHex,
                            showError: _showClientColorError,
                            onColorSelected: (hex) {
                              setModalState(() {
                                _selectedClientColorHex = normalizeClientColorHex(hex);
                                _showClientColorError = false;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _plannedBudgetController,
                            decoration: InputDecoration(
                              labelText: _isRetainerClient(client)
                                  ? 'Retainer amount (\$)'
                                  : 'Planned budget (\$) (optional)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (_isRetainerClient(client)) {
                                if (trimmed.isEmpty) {
                                  return 'Enter a retainer amount';
                                }
                                final parsed = double.tryParse(
                                  trimmed.replaceAll(',', '.'),
                                );
                                if (parsed == null || parsed <= 0) {
                                  return 'Enter a valid amount';
                                }
                              } else if (trimmed.isNotEmpty) {
                                final parsed = double.tryParse(
                                  trimmed.replaceAll(',', '.'),
                                );
                                if (parsed == null || parsed < 0) {
                                  return 'Enter a valid budget';
                                }
                              }
                              return null;
                            },
                          ),
                          if (_isRetainerClient(client)) ...[
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedRetainerFrequency,
                              decoration: const InputDecoration(
                                labelText: 'Payment frequency',
                              ),
                              items: _retainerFrequencyLabels.entries
                                  .map(
                                    (entry) => DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setModalState(() {
                                  _selectedRetainerFrequency = value;
                                });
                              },
                              validator: (value) {
                                if (!_isRetainerClient(client)) {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'Select a payment frequency';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Next payment date'),
                              subtitle: Text(
                                _selectedRetainerPayDate == null
                                    ? 'Select a date'
                                    : _formatDate(_selectedRetainerPayDate!),
                              ),
                              trailing: const Icon(Icons.calendar_today_outlined),
                              onTap: () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: routeContext,
                                  initialDate: _selectedRetainerPayDate ?? now,
                                  firstDate: now,
                                  lastDate: DateTime(now.year + 5),
                                );
                                if (picked == null) {
                                  return;
                                }
                                setModalState(() {
                                  _selectedRetainerPayDate = picked;
                                });
                              },
                            ),
                            if (_selectedRetainerPayDate == null)
                              Text(
                                'Select a payment date',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                              ),
                          ],
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contactNameController,
                            decoration: const InputDecoration(
                              labelText: 'Contact person',
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _contactPhoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _contactEmailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _contactTelegramController,
                            decoration: const InputDecoration(
                              labelText: 'Telegram',
                              hintText: '@username',
                            ),
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: SafeArea(
                  minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(routeContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final isValid =
                                _clientFormKey.currentState?.validate() ?? false;
                            final hasColor = _selectedClientColorHex.trim().isNotEmpty;
                            if (!hasColor) {
                              setModalState(() {
                                _showClientColorError = true;
                              });
                              return;
                            }
                            if (_isRetainerClient(client) &&
                                _selectedRetainerPayDate == null) {
                              setModalState(() {});
                              return;
                            }
                            if (!isValid) {
                              return;
                            }
                            Navigator.of(routeContext).pop();
                            _updateClientFromForm(client);
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateClientFromForm(Client client) async {
    final contactName = _contactNameController.text.trim();
    final contactPhone = _contactPhoneController.text.trim();
    final contactEmail = _contactEmailController.text.trim();
    final contactTelegram = _contactTelegramController.text.trim();
    final notesValue = _clientNotesController.text.trim();
    final plannedBudgetValue = _plannedBudgetController.text.trim();
    final plannedBudget = plannedBudgetValue.isEmpty
        ? null
        : double.tryParse(plannedBudgetValue.replaceAll(',', '.'));
    final now = DateTime.now();
    final normalizedColor = normalizeClientColorHex(_selectedClientColorHex);
    debugPrint(
      'Client color update (before): client=${client.id} old=${client.avatarColorHex}',
    );
    debugPrint(
      'Client color update (payload): client=${client.id} color=$normalizedColor',
    );
    final retainerSettings = _isRetainerClient(client)
        ? RetainerSettings(
            amount: plannedBudget ?? 0,
            frequency: _selectedRetainerFrequency ?? 'once_month',
            nextPaymentDate: _selectedRetainerPayDate ?? now,
            isEnabled: client.retainerSettings?.isEnabled ?? true,
            updatedAt: now,
          )
        : null;

    final updatedClient = Client(
      id: client.id,
      name: _clientNameController.text.trim(),
      type: client.type,
      contactPerson: contactName.isEmpty ? null : contactName,
      phone: contactPhone.isEmpty ? null : contactPhone,
      email: contactEmail.isEmpty ? null : contactEmail,
      telegram: contactTelegram.isEmpty ? null : contactTelegram,
      notes: notesValue.isEmpty ? null : notesValue,
      plannedBudget: _isRetainerClient(client) ? null : plannedBudget,
      createdAt: client.createdAt,
      updatedAt: now,
      avatarColorHex: normalizedColor,
      retainerSettings: retainerSettings,
    );
    await _updateClient(updatedClient);
  }

  Future<void> _duplicateClient(Client client) async {
    final nameController = TextEditingController();
    var copyWithAllSettings = true;
    var isValid = false;

    final shouldDuplicate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Duplicate client'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: copyWithAllSettings,
                    title: const Text('Copy with all settings?'),
                    onChanged: (value) {
                      setDialogState(() {
                        copyWithAllSettings = value ?? true;
                      });
                    },
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'New name',
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        isValid = value.trim().isNotEmpty;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isValid
                      ? () => Navigator.of(dialogContext).pop(true)
                      : null,
                  child: const Text('Create copy'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldDuplicate != true) {
      return;
    }
    final newName = nameController.text.trim();
    if (newName.isEmpty) {
      return;
    }
    await _duplicateClientWithName(client, newName, copyWithAllSettings);
    if (!mounted) {
      return;
    }
    _showSnackBar(context, 'Client duplicated');
  }

  Future<Client> _duplicateClientWithName(
    Client client,
    String newName,
    bool copyWithAllSettings,
  ) async {
    final now = DateTime.now();
    final newClientId = _generateId();
    final shouldCopyRetainer = _isRetainerClient(client) && copyWithAllSettings;
    final retainerSettings = shouldCopyRetainer && client.retainerSettings != null
        ? RetainerSettings(
            amount: client.retainerSettings!.amount,
            frequency: client.retainerSettings!.frequency,
            nextPaymentDate: client.retainerSettings!.nextPaymentDate,
            isEnabled: client.retainerSettings!.isEnabled,
            updatedAt: now,
          )
        : null;

    final duplicatedClient = Client(
      id: newClientId,
      name: newName,
      type: client.type,
      contactPerson: client.contactPerson,
      phone: client.phone,
      email: client.email,
      telegram: client.telegram,
      notes: copyWithAllSettings ? client.notes : null,
      plannedBudget: client.plannedBudget,
      createdAt: now,
      updatedAt: now,
      avatarColorHex: normalizeClientColorHex(client.avatarColorHex),
      retainerSettings: retainerSettings,
    );

    setState(() {
      _clients.add(duplicatedClient);
      if (!_isRetainerClient(client) && copyWithAllSettings) {
        final projectsToCopy =
            _projects.where((project) => project.clientId == client.id).toList();
        final projectIdMap = <String, String>{};
        for (final project in projectsToCopy) {
          final newProjectId = _generateId();
          projectIdMap[project.id] = newProjectId;
          _projects.add(
            Project(
              id: newProjectId,
              clientId: newClientId,
              title: project.title,
              amount: project.amount,
              status: project.status,
              deadlineDate: project.deadlineDate,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
        final paymentsToCopy = _projectPayments.where(
          (payment) => projectIdMap.containsKey(payment.projectId),
        );
        for (final payment in paymentsToCopy) {
          _projectPayments.add(
            ProjectPayment(
              id: _generateId(),
              projectId: projectIdMap[payment.projectId] ?? payment.projectId,
              amount: payment.amount,
              kind: payment.kind,
              status: payment.status,
              dueDate: payment.dueDate,
              paidDate: payment.paidDate,
              createdAt: payment.createdAt,
              updatedAt: now,
            ),
          );
        }
      }
    });
    await _persistData();
    return duplicatedClient;
  }

  Future<void> _addClient() async {
    final contractType = _selectedContractType ?? 'project';
    final contactName = _contactNameController.text.trim();
    final contactPhone = _contactPhoneController.text.trim();
    final contactEmail = _contactEmailController.text.trim();
    final contactTelegram = _contactTelegramController.text.trim();
    final notesValue = _clientNotesController.text.trim();
    final plannedBudgetValue = _plannedBudgetController.text.trim();
    final plannedBudget = plannedBudgetValue.isEmpty
        ? null
        : double.tryParse(plannedBudgetValue.replaceAll(',', '.'));
    final now = DateTime.now();
    final retainerSettings = contractType == 'retainer'
        ? RetainerSettings(
            amount: plannedBudget ?? 0,
            frequency: _selectedRetainerFrequency ?? 'once_month',
            nextPaymentDate: _selectedRetainerPayDate ?? now,
            isEnabled: true,
            updatedAt: now,
          )
        : null;

    final localColor = normalizeClientColorHex(_selectedClientColorHex);
    final feedback = OperationFeedback(context);
    feedback.showProgress(OperationKind.create);
    final newClient = Client(
      id: _generateId(),
      name: _clientNameController.text.trim(),
      type: contractType,
      contactPerson: contactName.isEmpty ? null : contactName,
      phone: contactPhone.isEmpty ? null : contactPhone,
      email: contactEmail.isEmpty ? null : contactEmail,
      telegram: contactTelegram.isEmpty ? null : contactTelegram,
      notes: notesValue.isEmpty ? null : notesValue,
      plannedBudget: contractType == 'project' ? plannedBudget : null,
      createdAt: now,
      updatedAt: now,
      avatarColorHex: localColor,
      retainerSettings: retainerSettings,
    );
    setState(() {
      debugPrint(
        'Client color create (local): client=${newClient.id} color=$localColor',
      );
      _clients.add(newClient);
    });
    final saved = await _persistData();
    if (!mounted) {
      return;
    }
    if (!saved) {
      feedback.showFailure(OperationKind.create);
      return;
    }
    final refreshedClient = _clientById(newClient.id);
    debugPrint(
      'Client color create (after sync): client=${newClient.id} color=${refreshedClient?.avatarColorHex ?? 'missing'}',
    );
    feedback.showSuccess(OperationKind.create);
  }

  bool _isRetainerClient(Client client) {
    return client.type == 'retainer';
  }

  List<Client> _projectEligibleClients() {
    return _clients.where((client) => !_isRetainerClient(client)).toList();
  }

  void _openProjectFormFromMenu() {
    if (_clients.isEmpty) {
      _showSnackBar(context, 'Create a client first');
      return;
    }
    if (_projectEligibleClients().isEmpty) {
      _showSnackBar(context, 'Create a project client first');
      return;
    }
    _showProjectForm();
  }

  void _openPaymentFormFromMenu() {
    final hasProjects = _projects.any(
      (project) => _clientById(project.clientId) != null,
    );
    if (!hasProjects) {
      _showSnackBar(context, 'Create a project first');
      return;
    }
    _showPaymentForm();
  }

  void _showProjectForm() {
    final eligibleClients = _projectEligibleClients();
    if (eligibleClients.isEmpty) {
      _showSnackBar(context, 'Create a project client first');
      return;
    }
    _projectNameController.clear();
    _projectAmountController.clear();
    _selectedProjectClient = null;
    _selectedProjectStage = 'first_meeting';
    _selectedProjectDeadline = null;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (routeContext) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;
              return Scaffold(
                appBar: AppBar(
                  title: const Text('New project'),
                ),
                body: SafeArea(
                  child: Form(
                    key: _projectFormKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedProjectClient,
                            decoration: const InputDecoration(
                              labelText: 'Client',
                            ),
                            items: eligibleClients
                                .map(
                                  (client) => DropdownMenuItem(
                                    value: client.id,
                                    child: Text(
                                      client.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setModalState(() {
                                _selectedProjectClient = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Select a client';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _projectNameController,
                            decoration: const InputDecoration(
                              labelText: 'Project name',
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter a project name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _projectAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Project amount (\$)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter a project amount';
                              }
                              final parsed = double.tryParse(
                                value.replaceAll(',', '.'),
                              );
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedProjectStage,
                            decoration: const InputDecoration(
                              labelText: 'Project stage',
                            ),
                            items: projectStageLabels.entries
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setModalState(() {
                                _selectedProjectStage = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Select a project stage';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Deadline (optional)'),
                            subtitle: Text(
                              _selectedProjectDeadline == null
                                  ? 'Select a date'
                                  : _formatDate(_selectedProjectDeadline!),
                            ),
                            trailing: const Icon(Icons.calendar_today_outlined),
                            onTap: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: routeContext,
                                initialDate: _selectedProjectDeadline ?? now,
                                firstDate: now,
                                lastDate: DateTime(now.year + 5),
                              );
                              if (picked == null) {
                                return;
                              }
                              setModalState(() {
                                _selectedProjectDeadline = picked;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: SafeArea(
                  minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(routeContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final isValid =
                                _projectFormKey.currentState?.validate() ?? false;
                            if (!isValid) {
                              return;
                            }
                            Navigator.of(routeContext).pop();
                            _addProject();
                          },
                          child: const Text('Add project'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPaymentForm() {
    _paymentAmountController.clear();
    _selectedPaymentProjectId = null;
    _selectedPaymentKind = null;
    _selectedPaymentDueDate = null;
    _selectedPaymentPaidDate = null;
    _selectedPaymentStatus = 'planned';

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (routeContext) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;
              final projectOptions = _projects
                  .where((project) => _clientById(project.clientId) != null)
                  .toList();
              return Scaffold(
                appBar: AppBar(
                  title: const Text('New payment'),
                ),
                body: SafeArea(
                  child: Form(
                    key: _paymentFormKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedPaymentProjectId,
                            decoration: const InputDecoration(
                              labelText: 'Project',
                            ),
                            items: projectOptions
                                .map(
                                  (project) => DropdownMenuItem(
                                    value: project.id,
                                    child: Text(
                                      '${_clientNameForId(project.clientId)} • ${project.title}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setModalState(() {
                                _selectedPaymentProjectId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Select a project';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _paymentAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Payment amount (\$)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter a payment amount';
                              }
                              final parsed = double.tryParse(
                                value.replaceAll(',', '.'),
                              );
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedPaymentKind,
                            decoration: const InputDecoration(
                              labelText: 'Payment kind',
                            ),
                            items: _paymentKindLabels.entries
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setModalState(() {
                                _selectedPaymentKind = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Select a payment kind';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedPaymentStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'planned', child: Text('Planned')),
                              DropdownMenuItem(value: 'paid', child: Text('Paid')),
                            ],
                            onChanged: (value) {
                              setModalState(() {
                                _selectedPaymentStatus = value;
                                if (value != 'paid') {
                                  _selectedPaymentPaidDate = null;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Due date (optional)'),
                            subtitle: Text(
                              _selectedPaymentDueDate == null
                                  ? 'Select a date'
                                  : _formatDate(_selectedPaymentDueDate!),
                            ),
                            trailing: const Icon(Icons.calendar_today_outlined),
                            onTap: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: routeContext,
                                initialDate: _selectedPaymentDueDate ?? now,
                                firstDate: DateTime(now.year - 5),
                                lastDate: DateTime(now.year + 5),
                              );
                              if (picked == null) {
                                return;
                              }
                              setModalState(() {
                                _selectedPaymentDueDate = picked;
                              });
                            },
                          ),
                          if (_selectedPaymentStatus == 'paid') ...[
                            const SizedBox(height: 12),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Paid date'),
                              subtitle: Text(
                                _selectedPaymentPaidDate == null
                                    ? 'Select a date'
                                    : _formatDate(_selectedPaymentPaidDate!),
                              ),
                              trailing: const Icon(Icons.calendar_today_outlined),
                              onTap: () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: routeContext,
                                  initialDate: _selectedPaymentPaidDate ?? now,
                                  firstDate: DateTime(now.year - 5),
                                  lastDate: DateTime(now.year + 5),
                                );
                                if (picked == null) {
                                  return;
                                }
                                setModalState(() {
                                  _selectedPaymentPaidDate = picked;
                                });
                              },
                            ),
                            if (_selectedPaymentPaidDate == null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Select a paid date',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: SafeArea(
                  minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(routeContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final isValid =
                                _paymentFormKey.currentState?.validate() ?? false;
                            if (_selectedPaymentStatus == 'paid' &&
                                _selectedPaymentPaidDate == null) {
                              setModalState(() {});
                              return;
                            }
                            if (!isValid) {
                              return;
                            }
                            Navigator.of(routeContext).pop();
                            _addPayment();
                          },
                          child: const Text('Add payment'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addPayment() async {
    final projectId = _selectedPaymentProjectId;
    if (projectId == null) {
      _showSnackBar(context, 'Select a project');
      return;
    }
    final amount =
        double.tryParse(_paymentAmountController.text.trim().replaceAll(',', '.')) ?? 0;
    final kind = _selectedPaymentKind ?? 'other';
    final status = _selectedPaymentStatus ?? 'planned';
    final now = DateTime.now();
    final feedback = OperationFeedback(context);
    feedback.showProgress(OperationKind.create);

    setState(() {
      _projectPayments.add(
        ProjectPayment(
          id: _generateId(),
          projectId: projectId,
          amount: amount,
          kind: kind,
          status: status,
          dueDate: _selectedPaymentDueDate,
          paidDate: status == 'paid' ? (_selectedPaymentPaidDate ?? now) : null,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
    final saved = await _persistData();
    if (!mounted) {
      return;
    }
    if (!saved) {
      feedback.showFailure(OperationKind.create);
      return;
    }
    feedback.showSuccess(OperationKind.create);
  }

  Future<void> _addProject() async {
    final clientId = _selectedProjectClient;
    if (clientId == null) {
      _showSnackBar(context, 'Select a client');
      return;
    }
    if (!_isValidUuid(clientId)) {
      _showSnackBar(context, 'Selected client ID is invalid.');
      return;
    }
    final client = _clients.firstWhere((item) => item.id == clientId);
    if (_isRetainerClient(client)) {
      _showSnackBar(context, 'Retainer clients cannot have projects');
      return;
    }
    final stage = _selectedProjectStage ?? 'first_meeting';
    if (!isValidProjectStage(stage)) {
      _showSnackBar(context, 'Select a valid project stage');
      return;
    }
    final deadline = _selectedProjectDeadline;
    final amount = double.tryParse(
          _projectAmountController.text.trim().replaceAll(',', '.'),
        ) ??
        0;
    if (amount <= 0) {
      _showSnackBar(context, 'Enter a valid project amount');
      return;
    }
    final title = _projectNameController.text.trim();
    if (title.isEmpty) {
      _showSnackBar(context, 'Enter a project name');
      return;
    }
    final now = DateTime.now();
    final newProject = Project(
      id: _generateId(),
      clientId: client.id,
      title: title,
      amount: amount,
      status: stage,
      deadlineDate: deadline,
      createdAt: now,
      updatedAt: now,
    );
    final feedback = OperationFeedback(context);
    feedback.showProgress(OperationKind.create);
    try {
      _syncStatusController.setLoading();
      final saved = await _repository.createProject(newProject);
      if (!mounted) {
        return;
      }
      setState(() {
        _projects.add(saved);
      });
      final refreshed = await _bootstrapData();
      if (!mounted || !refreshed) {
        return;
      }
      _syncStatusController.setSynced();
      feedback.showSuccess(OperationKind.create);
    } catch (error) {
      if (!mounted) {
        return;
      }
      debugPrint('Project create failed: $error');
      feedback.showFailure(OperationKind.create);
    }
  }

  Future<void> _addProjectFromDetails(Project project) async {
    final feedback = OperationFeedback(context);
    feedback.showProgress(OperationKind.create);
    try {
      _syncStatusController.setLoading();
      final saved = await _repository.createProject(project);
      if (!mounted) {
        return;
      }
      setState(() {
        _projects.add(saved);
      });
      final refreshed = await _bootstrapData();
      if (!mounted || !refreshed) {
        return;
      }
      _syncStatusController.setSynced();
      feedback.showSuccess(OperationKind.create);
    } catch (error) {
      if (!mounted) {
        return;
      }
      debugPrint('Project create failed: $error');
      feedback.showFailure(OperationKind.create);
    }
  }

  Future<void> _deleteProject(Project project) async {
    final feedback = OperationFeedback(context);
    feedback.showProgress(OperationKind.delete);
    setState(() {
      _projects.remove(project);
      _projectPayments.removeWhere((payment) => payment.projectId == project.id);
    });
    final saved = await _persistData();
    if (!mounted) {
      return;
    }
    if (!saved) {
      feedback.showFailure(OperationKind.delete);
      return;
    }
    feedback.showSuccess(OperationKind.delete);
  }

  Future<void> _updateProject(Project oldProject, Project updatedProject) async {
    final feedback = OperationFeedback(context);
    feedback.showProgress(OperationKind.update);
    setState(() {
      final index = _projects.indexOf(oldProject);
      if (index != -1) {
        _projects[index] = updatedProject;
      }
    });
    final saved = await _persistData();
    if (!mounted) {
      return;
    }
    if (!saved) {
      feedback.showFailure(OperationKind.update);
      return;
    }
    feedback.showSuccess(OperationKind.update);
  }

  Future<void> _updateProjectPayment(
    ProjectPayment oldPayment,
    ProjectPayment updatedPayment,
  ) async {
    final feedback = OperationFeedback(context);
    feedback.showProgress(OperationKind.update);
    setState(() {
      final index = _projectPayments.indexOf(oldPayment);
      if (index != -1) {
        _projectPayments[index] = updatedPayment;
      }
    });
    final saved = await _persistData();
    if (!mounted) {
      return;
    }
    if (!saved) {
      feedback.showFailure(OperationKind.update);
      return;
    }
    feedback.showSuccess(OperationKind.update);
  }

  Future<void> _deleteProjectPayment(ProjectPayment payment) async {
    final feedback = OperationFeedback(context);
    feedback.showProgress(OperationKind.delete);
    setState(() {
      _projectPayments.remove(payment);
    });
    final saved = await _persistData();
    if (!mounted) {
      return;
    }
    if (!saved) {
      feedback.showFailure(OperationKind.delete);
      return;
    }
    feedback.showSuccess(OperationKind.delete);
  }

  Future<Project> _duplicateProject(
    Project project,
    String newTitle,
    bool copyWithAllSettings,
  ) async {
    final now = DateTime.now();
    final duplicated = Project(
      id: _generateId(),
      clientId: project.clientId,
      title: newTitle,
      amount: project.amount,
      status: project.status,
      deadlineDate: project.deadlineDate,
      createdAt: now,
      updatedAt: now,
    );
    await _addProjectFromDetails(duplicated);
    if (copyWithAllSettings) {
      final matchingPayments = _projectPayments
          .where((payment) => payment.projectId == project.id)
          .toList();
      if (matchingPayments.isNotEmpty) {
        setState(() {
          for (final payment in matchingPayments) {
            _projectPayments.add(
              ProjectPayment(
                id: _generateId(),
                projectId: duplicated.id,
                amount: payment.amount,
                kind: payment.kind,
                status: payment.status,
                dueDate: payment.dueDate,
                paidDate: payment.paidDate,
                createdAt: payment.createdAt,
                updatedAt: now,
              ),
            );
          }
        });
        await _persistData();
      }
    }
    return duplicated;
  }

  Future<void> _deleteClient(Client client) async {
    final feedback = OperationFeedback(context);
    feedback.showProgress(OperationKind.delete);
    setState(() {
      _clients.remove(client);
      final projectIds = _projects
          .where((project) => project.clientId == client.id)
          .map((project) => project.id)
          .toSet();
      _projects.removeWhere((project) => project.clientId == client.id);
      _projectPayments
          .removeWhere((payment) => projectIds.contains(payment.projectId));
    });
    final saved = await _persistData();
    if (!mounted) {
      return;
    }
    if (!saved) {
      feedback.showFailure(OperationKind.delete);
      return;
    }
    feedback.showSuccess(OperationKind.delete);
  }

  Future<void> _openClientDetails(
    Client client, {
    bool openRetainerSettings = false,
  }) async {
    final clientProjects =
        _projects.where((project) => project.clientId == client.id).toList();
    final projectIds = clientProjects.map((project) => project.id).toSet();
    final clientPayments = _projectPayments
        .where((payment) => projectIds.contains(payment.projectId))
        .toList();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClientDetailScreen(
          client: client,
          projects: clientProjects,
          payments: clientPayments,
          openRetainerSettings: openRetainerSettings,
          isLoading: _isLoading,
          onDeleteClient: () => _deleteClient(client),
          onUpdateClient: _updateClient,
          onDuplicateClient: (source, newName, copyWithAllSettings) =>
              _duplicateClientWithName(source, newName, copyWithAllSettings),
          onUpdatePayment: _updateProjectPayment,
          onDeletePayment: _deleteProjectPayment,
          onDuplicateProject: _duplicateProject,
          onUpdateProject: _updateProject,
          onDeleteProject: _deleteProject,
        ),
      ),
    );
  }

  void _updateClientStatusFilter(String? status) {
    setState(() {
      _selectedClientStatus = status;
    });
  }

  Future<void> _updateClient(Client updatedClient) async {
    final feedback = OperationFeedback(context);
    feedback.showProgress(OperationKind.update);
    final previousIndex =
        _clients.indexWhere((client) => client.id == updatedClient.id);
    final previousClient =
        previousIndex == -1 ? null : _clients[previousIndex];
    setState(() {
      if (previousIndex != -1) {
        _clients[previousIndex] = updatedClient;
      }
    });
    final saved = await _persistData();
    if (!saved && previousClient != null && mounted) {
      setState(() {
        final rollbackIndex =
            _clients.indexWhere((client) => client.id == updatedClient.id);
        if (rollbackIndex != -1) {
          _clients[rollbackIndex] = previousClient;
        }
      });
    }
    if (!mounted) {
      return;
    }
    if (!saved) {
      feedback.showFailure(OperationKind.update);
      return;
    }
    final refreshedClient = _clientById(updatedClient.id);
    final refreshedColor = refreshedClient?.avatarColorHex ?? 'missing';
    debugPrint(
      'Client color update (after): client=${updatedClient.id} color=$refreshedColor',
    );
    feedback.showSuccess(OperationKind.update);
  }

  String _clientTypeLabel(Client client) {
    return _isRetainerClient(client) ? 'Retainer' : 'Project';
  }

  Color _clientCardColor(BuildContext context, Client client) {
    final base = Theme.of(context).colorScheme.surface;
    final tint = _clientTagColor(client);
    return Color.alphaBlend(tint.withOpacity(0.12), base);
  }

  Color _clientTagColor(Client client) {
    return _isRetainerClient(client)
        ? const Color(0xFFE7DCCA)
        : const Color(0xFFD9E4EC);
  }

  Color _clientColor(Client client) {
    return resolveClientColor(client);
  }

  Color _clientColorForId(String clientId) {
    final client = _clientById(clientId);
    if (client == null) {
      return Theme.of(context).colorScheme.surfaceVariant;
    }
    return _clientColor(client);
  }

  Color _clientAvatarColor(Client client) {
    return _clientColor(client);
  }

  Color _paymentPillColor(BuildContext context, _PaymentPillItem item) {
    return _clientColorForId(item.clientId);
  }

  String _clientInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final letters = trimmed.replaceAll(RegExp(r'\s+'), '');
    return letters.length >= 2
        ? letters.substring(0, 2).toUpperCase()
        : letters.substring(0, 1).toUpperCase();
  }

  _AvatarColorUpdate _ensureClientAvatarColors(List<Client> clients) {
    var updated = false;
    final now = DateTime.now();
    final updatedClients = clients.map((client) {
      if (client.avatarColorHex.trim().isNotEmpty) {
        return client;
      }
      updated = true;
      return Client(
        id: client.id,
        name: client.name,
        type: client.type,
        contactPerson: client.contactPerson,
        phone: client.phone,
        email: client.email,
        telegram: client.telegram,
        notes: client.notes,
        plannedBudget: client.plannedBudget,
        createdAt: client.createdAt,
        updatedAt: now,
        avatarColorHex: defaultClientColorHex(),
        retainerSettings: client.retainerSettings,
      );
    }).toList();

    return _AvatarColorUpdate(
      clients: updatedClients,
      updated: updated,
    );
  }

  double _clientTotalAmount(Client client) {
    if (_isRetainerClient(client)) {
      return client.retainerSettings?.amount ?? 0;
    }
    final projectIds = _projects
        .where((project) => project.clientId == client.id)
        .map((project) => project.id)
        .toSet();
    final plannedSum = _projectPayments
        .where((payment) => projectIds.contains(payment.projectId))
        .fold<double>(0, (sum, payment) => sum + payment.amount);
    if (plannedSum != 0) {
      return plannedSum;
    }
    final projectAmountSum = _projects
        .where((project) => project.clientId == client.id)
        .fold<double>(0, (sum, project) => sum + project.amount);
    return projectAmountSum == 0 ? (client.plannedBudget ?? 0) : projectAmountSum;
  }

  List<_UpcomingPaymentEntry> _buildUpcomingPayments(DateTime start, DateTime end) {
    final upcoming = <_UpcomingPaymentEntry>[];
    final projectKindCounts = <String, int>{};
    var retainerCount = 0;

    for (final entry in _retainerUpcomingPayments(start, end)) {
      retainerCount += 1;
      upcoming.add(
        _UpcomingPaymentEntry(
          clientId: entry.clientId,
          clientName: entry.clientName,
          amount: entry.amount,
          date: entry.date,
          createdAt:
              _clientById(entry.clientId)?.retainerSettings?.updatedAt ?? entry.date,
          tagLabel: 'salary',
          type: _PaymentPillType.retainer,
        ),
      );
    }

    for (final payment in _projectPayments) {
      if (payment.dueDate == null) {
        continue;
      }
      if (!_isWithinRange(payment.dueDate!, start, end)) {
        continue;
      }
      final project = _projectById(payment.projectId);
      if (project == null) {
        continue;
      }
      final client = _clientById(project.clientId);
      if (client == null) {
        continue;
      }
      final kindKey = payment.kind;
      projectKindCounts[kindKey] = (projectKindCounts[kindKey] ?? 0) + 1;
      upcoming.add(
        _UpcomingPaymentEntry(
          clientId: client.id,
          clientName: client.name,
          amount: payment.amount,
          date: payment.dueDate!,
          createdAt: payment.createdAt,
          tagLabel: 'project',
          type: _PaymentPillType.project,
          projectId: project.id,
          sourcePayment: payment,
        ),
      );
    }

    debugPrint(
      'Upcoming payments window ${_formatDate(start)}-${_formatDate(end)} '
      'project_counts=$projectKindCounts retainers=$retainerCount total=${upcoming.length}',
    );

    upcoming.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return upcoming;
  }

  List<_PaymentPillItem> _paymentPillItemsFromEntries(
    List<_UpcomingPaymentEntry> entries,
  ) {
    return entries
        .map(
          (entry) => _PaymentPillItem(
            clientId: entry.clientId,
            clientName: entry.clientName,
            amount: entry.amount,
            date: entry.date,
            tagLabel: entry.tagLabel,
            type: entry.type,
            projectId: entry.projectId,
          ),
        )
        .toList();
  }

  Iterable<_UpcomingPayment> _retainerUpcomingPayments(DateTime start, DateTime end) sync* {
    for (final client in _visibleClients()) {
      if (client.type != 'retainer') {
        continue;
      }
      final settings = client.retainerSettings;
      if (settings == null || !settings.isEnabled) {
        continue;
      }
      final scheduledDates = _scheduledRetainerDates(settings, start, end);
      for (final date in scheduledDates) {
        yield _UpcomingPayment(
          clientId: client.id,
          clientName: client.name,
          amount: settings.amount,
          date: date,
          kind: 'Retainer',
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isWithinRange(DateTime date, DateTime start, DateTime end) {
    final normalizedDate = _normalizeDate(date);
    final normalizedStart = _normalizeDate(start);
    final normalizedEnd = _normalizeDate(end);
    return !normalizedDate.isBefore(normalizedStart) && !normalizedDate.isAfter(normalizedEnd);
  }

  List<Client> _visibleClients() {
    return _clients.toList();
  }

  Client? _clientById(String id) {
    return _clients.cast<Client?>().firstWhere(
          (client) => client?.id == id,
          orElse: () => null,
        );
  }

  Project? _projectById(String id) {
    return _projects.cast<Project?>().firstWhere(
          (project) => project?.id == id,
          orElse: () => null,
        );
  }

  String _clientNameForId(String clientId) {
    return _clientById(clientId)?.name ?? 'Unknown client';
  }

  bool _isActiveProject(Project project) {
    return project.status != 'payment_received_in_full';
  }

  List<Project> _activeProjects() {
    return _projects.where((project) {
      final client = _clientById(project.clientId);
      return client != null && _isActiveProject(project);
    }).toList();
  }

  List<Project> _sortedMilestoneProjects(List<Project> projects) {
    final sorted = projects.toList();
    sorted.sort((a, b) {
      final aHasDeadline = a.deadlineDate != null;
      final bHasDeadline = b.deadlineDate != null;
      if (aHasDeadline != bHasDeadline) {
        return aHasDeadline ? -1 : 1;
      }
      final aDate = a.deadlineDate ?? a.updatedAt;
      final bDate = b.deadlineDate ?? b.updatedAt;
      final dateCompare = aDate.compareTo(bDate);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return sorted;
  }

  Set<String> _activeProjectClients(List<Project> activeProjects) {
    return activeProjects
        .map((project) => project.clientId)
        .where((id) => _clientById(id)?.type == 'project')
        .toSet();
  }

  void _openMilestonesDeadlines(List<Project> projects) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MilestonesDeadlinesScreen(
          projects: projects,
          clientNameForId: _clientNameForId,
          formatCurrency: _formatCurrency,
          stageProgress: _projectStageProgress,
          stageColor: _projectStageColor,
          onProjectTap: (project) {
            final client = _clientById(project.clientId);
            if (client == null) {
              return;
            }
            _openClientDetails(client);
          },
        ),
      ),
    );
  }

  List<Project> _deadlineProjects(DateTime start, DateTime end) {
    return _activeProjects()
        .where(
          (project) =>
              project.deadlineDate != null &&
              _isWithinRange(project.deadlineDate!, start, end),
        )
        .toList();
  }

  double _retainerScheduledSum(DateTime start, DateTime end) {
    return _retainerUpcomingPayments(start, end).fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );
  }

  double _projectBudgetSum() {
    var total = 0.0;
    for (final project in _activeProjects()) {
      final payments = _projectPayments
          .where((payment) => payment.projectId == project.id)
          .toList();
      if (payments.isEmpty) {
        total += project.amount;
      } else {
        total += payments.fold<double>(0, (sum, payment) => sum + payment.amount);
      }
    }
    return total;
  }

  List<DateTime> _scheduledRetainerDates(
    RetainerSettings settings,
    DateTime start,
    DateTime end,
  ) {
    final dates = <DateTime>[];
    var cursor = _normalizeDate(settings.nextPaymentDate);
    while (cursor.isBefore(start)) {
      cursor = settings.frequency == 'twice_month'
          ? cursor.add(const Duration(days: 14))
          : _addOneMonth(cursor);
    }
    while (!cursor.isAfter(end)) {
      dates.add(cursor);
      cursor = settings.frequency == 'twice_month'
          ? cursor.add(const Duration(days: 14))
          : _addOneMonth(cursor);
    }
    return dates;
  }

  DateTime _addOneMonth(DateTime date) {
    final year = date.year;
    final month = date.month + 1;
    final targetYear = month > 12 ? year + 1 : year;
    final targetMonth = month > 12 ? 1 : month;
    final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
    final day = date.day <= lastDay ? date.day : lastDay;
    return DateTime(targetYear, targetMonth, day);
  }

  String _generateId() {
    return const Uuid().v4();
  }

  bool _isValidUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-'
      r'[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(value);
  }

  String _formatInsertError(String resource, Object error) {
    if (error is PostgrestException) {
      final details = [
        'message=${error.message}',
        if (error.code != null) 'code=${error.code}',
        if (error.details != null) 'details=${error.details}',
        if (error.hint != null) 'hint=${error.hint}',
      ].join(', ');
      return 'Failed to create $resource: $details';
    }
    return 'Failed to create $resource: $error';
  }

  Future<void> _debugInsertProject() async {
    if (!kDebugMode) {
      return;
    }
    final clientId = await _repository.fetchFirstEligibleClientId();
    if (clientId == null) {
      _showSnackBar(context, 'No eligible clients available for debug insert.');
      return;
    }
    final now = DateTime.now();
    final project = Project(
      id: _generateId(),
      clientId: clientId,
      title: 'Debug project ${now.toIso8601String()}',
      amount: 1,
      status: 'first_meeting',
      deadlineDate: null,
      createdAt: now,
      updatedAt: now,
    );
    try {
      final saved = await _repository.createProject(project);
      debugPrint('Debug project insert succeeded: ${saved.toJson()}');
      if (!mounted) {
        return;
      }
      setState(() {
        _projects.add(saved);
      });
      _showSnackBar(context, 'Debug project inserted.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(context, _formatInsertError('debug project', error));
    }
  }

  void _showActiveProjectsSheet(List<Project> projects) {
    _showListSheet(
      title: 'Active projects',
      items: projects
          .map(
            (project) => _SheetItem(
              title: project.title,
              subtitle:
                  '${_clientNameForId(project.clientId)} • ${projectStageLabels[project.status] ?? project.status}',
              trailing: project.deadlineDate == null
                  ? null
                  : _formatDate(project.deadlineDate!),
            ),
          )
          .toList(),
      emptyLabel: 'No active projects.',
    );
  }

  void _showBudgetBreakdownSheet(
    DateTime start,
    DateTime end,
  ) {
    final retainerEntries = _retainerUpcomingPayments(start, end).toList();
    final activeProjects = _activeProjects();
    final projectPayments = <ProjectPayment>[];
    final projectsWithoutPayments = <Project>[];

    for (final project in activeProjects) {
      final payments = _projectPayments
          .where((payment) => payment.projectId == project.id)
          .toList();
      if (payments.isEmpty) {
        projectsWithoutPayments.add(project);
      } else {
        projectPayments.addAll(payments);
      }
    }

    _showListSheet(
      title: 'Budget in progress',
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Retainers next 30 days: ${_formatCurrency(_retainerScheduledSum(start, end))}',
          ),
          Text('Project commitments: ${_formatCurrency(_projectBudgetSum())}'),
          const SizedBox(height: 12),
          const Text('Retainer schedule'),
        ],
      ),
      items: [
        ...retainerEntries.map(
          (entry) => _SheetItem(
            title: entry.clientName,
            subtitle: 'Retainer • ${_formatDate(entry.date)}',
            trailing: _formatCurrency(entry.amount),
          ),
        ),
        if (retainerEntries.isNotEmpty) const _SheetDivider(),
        ...projectPayments.map(
          (payment) {
            final project = _projectById(payment.projectId);
            final clientName =
                project == null ? 'Unknown client' : _clientNameForId(project.clientId);
            return _SheetItem(
              title: project?.title ?? 'Unknown project',
              subtitle: '$clientName • ${_paymentKindLabels[payment.kind] ?? payment.kind}',
              trailing: _formatCurrency(payment.amount),
            );
          },
        ),
        if (projectsWithoutPayments.isNotEmpty) const _SheetDivider(),
        ...projectsWithoutPayments.map(
          (project) => _SheetItem(
            title: project.title,
            subtitle: '${_clientNameForId(project.clientId)} • Project total',
            trailing: _formatCurrency(project.amount),
          ),
        ),
      ],
      emptyLabel: 'No budget items available.',
    );
  }

  void _showDeadlinesSheet(List<Project> projects) {
    _showListSheet(
      title: 'Deadlines this week',
      items: projects
          .map(
            (project) => _SheetItem(
              title: project.title,
              subtitle: _clientNameForId(project.clientId),
              trailing: project.deadlineDate == null
                  ? null
                  : _formatDate(project.deadlineDate!),
            ),
          )
          .toList(),
      emptyLabel: 'No deadlines this week.',
    );
  }

  void _showUpcomingPaymentsSheet(DateTime start, DateTime end) {
    final upcomingEntries = _buildUpcomingPayments(start, end);

    _showListSheet(
      title: 'Upcoming payments',
      items: upcomingEntries
          .map(
            (entry) {
              final client = _clientById(entry.clientId);
              final project = entry.projectId == null
                  ? null
                  : _projectById(entry.projectId!);
              final subtitle = entry.type == _PaymentPillType.project
                  ? '${entry.clientName} • ${_paymentKindLabels[entry.sourcePayment?.kind] ?? entry.sourcePayment?.kind ?? 'Payment'} • ${_formatDate(entry.date)}'
                  : 'Retainer • ${_formatDate(entry.date)}';
              return _SheetItem(
                title: entry.type == _PaymentPillType.project
                    ? project?.title ?? entry.clientName
                    : entry.clientName,
                subtitle: subtitle,
                trailing: _formatCurrency(entry.amount),
                onTap: client == null ? null : () => _openClientDetails(client),
              );
            },
          )
          .toList(),
      emptyLabel: 'No payments this week.',
    );
  }

  void _showListSheet({
    required String title,
    required List<Widget> items,
    required String emptyLabel,
    Widget? header,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                if (header != null) ...[
                  header,
                  const SizedBox(height: 12),
                ],
                if (items.isEmpty)
                  Text(
                    emptyLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  )
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: items,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    final rounded = amount.round();
    final absolute = rounded.abs().toString();
    final formatted = absolute.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (match) => '${match[1]},',
    );
    final prefix = rounded < 0 ? '-' : '';
    return '\$$prefix$formatted';
  }

  double _projectStageProgress(String stage) {
    switch (stage) {
      case 'first_meeting':
        return 0.1;
      case 'deposit_received':
        return 0.2;
      case 'in_progress':
        return 0.35;
      case 'awaiting_feedback':
        return 0.5;
      case 'returned_for_revision':
        return 0.55;
      case 'renegotiating_budget':
        return 0.6;
      case 'project_on_hold':
        return 0.6;
      case 'payment_received_in_full':
        return 1.0;
      default:
        return 0.0;
    }
  }

  Color _projectStageColor(String stage) {
    switch (stage) {
      case 'awaiting_feedback':
        return const Color(0xFFF47A64);
      case 'returned_for_revision':
        return const Color(0xFFB8432D);
      case 'project_on_hold':
        return const Color(0xFF1F1C1B);
      default:
        return const Color(0xFF7AA37C);
    }
  }
}

enum _PaymentPillType { project, retainer }

class _PaymentPillItem {
  const _PaymentPillItem({
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.date,
    required this.tagLabel,
    required this.type,
    this.projectId,
  });

  final String clientId;
  final String clientName;
  final double amount;
  final DateTime date;
  final String tagLabel;
  final _PaymentPillType type;
  final String? projectId;
}

class _UpcomingPaymentEntry {
  const _UpcomingPaymentEntry({
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.date,
    required this.createdAt,
    required this.tagLabel,
    required this.type,
    this.projectId,
    this.sourcePayment,
  });

  final String clientId;
  final String clientName;
  final double amount;
  final DateTime date;
  final DateTime createdAt;
  final String tagLabel;
  final _PaymentPillType type;
  final String? projectId;
  final ProjectPayment? sourcePayment;
}

class _UpcomingPayment {
  const _UpcomingPayment({
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.date,
    required this.kind,
  });

  final String clientId;
  final String clientName;
  final double amount;
  final DateTime date;
  final String kind;
}

class _SheetItem extends StatelessWidget {
  const _SheetItem({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing == null ? null : Text(trailing!),
      onTap: onTap,
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 24);
  }
}

class _PaymentPill extends StatelessWidget {
  const _PaymentPill({
    required this.item,
    required this.formattedAmount,
    required this.formattedDate,
    required this.avatarColor,
    this.onTap,
  });

  final _PaymentPillItem item;
  final String formattedAmount;
  final String formattedDate;
  final Color avatarColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = item.type == _PaymentPillType.project
        ? Icons.payments_outlined
        : Icons.calendar_today_outlined;
    final iconColor = contrastColorFor(avatarColor);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: avatarColor,
                  child: Icon(
                    icon,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.clientName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: avatarColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.tagLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedAmount,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.client,
    required this.isRetainer,
    required this.initials,
    required this.typeLabel,
    required this.formattedAmount,
    required this.cardColor,
    required this.tagColor,
    required this.avatarColor,
    required this.onTap,
  });

  final Client client;
  final bool isRetainer;
  final String initials;
  final String typeLabel;
  final String formattedAmount;
  final Color cardColor;
  final Color tagColor;
  final Color avatarColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tagTextColor = isDark
        ? theme.colorScheme.onSurface.withOpacity(0.96)
        : theme.colorScheme.onSurfaceVariant;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: avatarColor,
                radius: 18,
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        typeLabel.toLowerCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: tagTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedAmount,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRetainer ? 'Salary' : 'Project total',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
