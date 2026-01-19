import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/client.dart';
import '../models/project.dart';
import '../models/project_payment.dart';
import '../models/retainer_settings.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import 'client_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Map<String, String> _projectStageLabels = {
    'first_meeting': 'First meeting',
    'deposit_received': 'Deposit received',
    'in_progress': 'In progress',
    'awaiting_feedback': 'Awaiting feedback',
    'returned_for_revision': 'Returned for revision',
    'renegotiating_budget': 'Renegotiating budget',
    'project_on_hold': 'Project on hold',
    'payment_received_in_full': 'Payment received in full',
  };
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
  late final Future<PackageInfo> _packageInfoFuture;
  final GlobalKey<FormState> _clientFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _projectFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _paymentFormKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _plannedBudgetController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactTelegramController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
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

  final List<Client> _clients = [];
  final List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _loadData();
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
    _projectNameController.dispose();
    _paymentAmountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  final List<ProjectPayment> _projectPayments = [];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = _normalizeDate(now);
    final range7End = today.add(const Duration(days: 6));
    final range30End = today.add(const Duration(days: 29));
    final activeProjects =
        _isLoading ? const <Project>[] : _activeProjects();
    final activeProjectsCount = activeProjects.length;
    final activeProjectClientsCount = _isLoading
        ? 0
        : _activeProjectClients(activeProjects).length;
    final retainerNext30 =
        _isLoading ? 0.0 : _retainerScheduledSum(today, range30End);
    final plannedProjectSum =
        _isLoading ? 0.0 : _plannedProjectPaymentsSum();
    final budgetInProgress = retainerNext30 + plannedProjectSum;
    final deadlinesThisWeek = _isLoading ? 0 : _deadlineProjects(today, range7End).length;
    final upcomingPayments = _isLoading
        ? 0.0
        : _projectPaymentsPaidThisWeek(today, range7End) +
            _retainerScheduledSum(today, range7End);
    final clientStatuses = _projectStageLabels.entries.toList();
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filteredProjects = normalizedQuery.isEmpty
        ? activeProjects
        : activeProjects
            .where(
              (project) =>
                  project.title.toLowerCase().contains(normalizedQuery) ||
                  _clientNameForId(project.clientId)
                      .toLowerCase()
                      .contains(normalizedQuery),
            )
            .toList();
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
    final upcomingPaymentItems =
        _isLoading ? const <_UpcomingPayment>[] : _buildUpcomingPayments(today);
    final filteredPayments = normalizedQuery.isEmpty
        ? upcomingPaymentItems
        : upcomingPaymentItems
            .where(
              (payment) =>
                  payment.client.toLowerCase().contains(normalizedQuery) ||
                  payment.kind.toLowerCase().contains(normalizedQuery),
            )
            .toList();
    final milestoneWidgets = _isLoading
        ? [_buildEmptyState('Loading milestones...')]
        : filteredProjects.isEmpty
            ? [_buildEmptyState('Add a project to track milestones.')]
            : filteredProjects
                .map(
                  (project) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  project.title,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Text(
                                project.deadlineDate == null
                                    ? '—'
                                    : _formatDate(project.deadlineDate!),
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _clientNameForId(project.clientId),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _projectStageLabels[project.status] ?? project.status,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                          child: LinearProgressIndicator(
                              value: _projectStageProgress(project.status),
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _projectStageColor(project.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList();
    final paymentWidgets = _isLoading
        ? [_buildEmptyState('Loading payments...')]
        : filteredPayments.isEmpty
            ? [_buildEmptyState('No payments expected in the next 30 days.')]
            : [
                Card(
                  child: Column(
                    children: [
                      ...filteredPayments.map(
                        (payment) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.payments,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(payment.client),
                          subtitle: Text('${payment.kind} • ${_formatDate(payment.date)}'),
                          trailing: Text(
                            '€${payment.amount.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total next 30 days',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              _formatCurrency(
                                filteredPayments.fold<double>(
                                  0,
                                  (sum, payment) => sum + payment.amount,
                                ),
                              ),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                    ),
                  ],
                ),
              ),
            ];
    final upcomingRetainerPayment = _nextRetainerPayment(DateTime.now());
    final clientWidgets = _isLoading
        ? [_buildEmptyState('Loading clients...')]
        : filteredClients.isEmpty
            ? [_buildEmptyState('Add a client to get started.')]
            : filteredClients
                .map(
                  (client) => _ClientCard(
                    client: client,
                    isRetainer: _isRetainerClient(client),
                    initials: _clientInitials(client.name),
                    typeLabel: _clientTypeLabel(client),
                    totalAmount: _clientTotalAmount(client),
                    cardColor: _clientCardColor(context, client),
                    onTap: () => _openClientDetails(client),
                  ),
                )
                .toList();

    return Scaffold(
      appBar: AppBar(
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
                    'Hi Basil',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<PackageInfo>(
                    future: _packageInfoFuture,
                    builder: (context, snapshot) {
                      final version = snapshot.data?.version;
                      final subtitle = version == null ? 'Jahrrr' : 'Jahrrr v$version';
                      return Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      );
                    },
                  ),
                ],
              ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.95,
            children: [
              StatCard(
                title: 'Active projects',
                value: activeProjectsCount.toString(),
                subtitle: 'Across $activeProjectClientsCount clients',
                color: Color(0xFF8CB7C9),
                onTap: () => _showActiveProjectsSheet(activeProjects),
              ),
              StatCard(
                title: 'Budget in progress',
                value: _formatCurrency(budgetInProgress),
                subtitle: 'Across $activeProjectsCount projects',
                color: Color(0xFF7AA37C),
                onTap: () => _showBudgetBreakdownSheet(
                  today,
                  range30End,
                ),
              ),
              StatCard(
                title: 'Deadlines this week',
                value: deadlinesThisWeek.toString(),
                subtitle: 'This week',
                color: Color(0xFFF47A64),
                onTap: () => _showDeadlinesSheet(
                  _deadlineProjects(today, range7End),
                ),
              ),
              StatCard(
                title: 'Upcoming payments',
                value: _formatCurrency(upcomingPayments),
                subtitle: 'This week',
                color: Color(0xFFB8432D),
                onTap: () => _showUpcomingPaymentsSheet(today, range7End),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Milestones & deadlines',
            actionLabel: 'View all',
            onActionPressed: () => _showSnackBar(context, 'Viewing all milestones'),
          ),
          const SizedBox(height: 12),
          ...milestoneWidgets,
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Payments',
            actionLabel: 'Add',
            onActionPressed: () {
              final hasProjects = _projects.any(
                (project) => _clientById(project.clientId)?.isArchived != true,
              );
              if (!hasProjects) {
                _showSnackBar(context, 'Create a project first');
                return;
              }
              _showPaymentForm();
            },
          ),
          const SizedBox(height: 12),
          if (upcomingRetainerPayment != null) ...[
            _UpcomingRetainerPaymentCard(
              payment: upcomingRetainerPayment,
              formattedAmount: _formatCurrency(upcomingRetainerPayment.amount),
              formattedDate: _formatDate(upcomingRetainerPayment.date),
            ),
            const SizedBox(height: 12),
          ],
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
      floatingActionButton: MenuAnchor(
        alignmentOffset: const Offset(0, -8),
        menuChildren: [
          MenuItemButton(
            leadingIcon: const Icon(Icons.person_add_outlined),
            onPressed: _showClientForm,
            child: const Text('New client'),
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.work_outline),
            onPressed: _openProjectFormFromMenu,
            child: const Text('New project'),
          ),
        ],
        builder: (context, controller, child) {
          return FloatingActionButton.small(
            tooltip: 'Just +',
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientsData = prefs.getString('clients');
      final projectsData = prefs.getString('projects');
      final paymentsData = prefs.getString('projectPayments');
      final legacyPaymentsData = prefs.getString('payments');
      if (clientsData != null) {
        final decoded = jsonDecode(clientsData) as List<dynamic>;
        _clients
          ..clear()
          ..addAll(
            decoded
                .whereType<Map<String, dynamic>>()
                .map(Client.fromJson),
          );
      }
      if (projectsData != null) {
        final decoded = jsonDecode(projectsData) as List<dynamic>;
        _projects
          ..clear()
          ..addAll(
            decoded
                .whereType<Map<String, dynamic>>()
                .map(Project.fromJson),
          );
      }
      if (paymentsData != null) {
        final decoded = jsonDecode(paymentsData) as List<dynamic>;
        _projectPayments
          ..clear()
          ..addAll(
            decoded
                .whereType<Map<String, dynamic>>()
                .map(ProjectPayment.fromJson),
          );
      } else if (legacyPaymentsData != null) {
        final decoded = jsonDecode(legacyPaymentsData) as List<dynamic>;
        _projectPayments
          ..clear()
          ..addAll(_migrateLegacyPayments(decoded));
      }
    } catch (_) {
      _clients.clear();
      _projects.clear();
      _projectPayments.clear();
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _persistData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'clients',
      jsonEncode(_clients.map((client) => client.toJson()).toList()),
    );
    await prefs.setString(
      'projects',
      jsonEncode(_projects.map((project) => project.toJson()).toList()),
    );
    await prefs.setString(
      'projectPayments',
      jsonEncode(_projectPayments.map((payment) => payment.toJson()).toList()),
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

  void _showClientForm() {
    _clientNameController.clear();
    _plannedBudgetController.clear();
    _contactNameController.clear();
    _contactPhoneController.clear();
    _contactEmailController.clear();
    _contactTelegramController.clear();
    _selectedContractType = null;
    _selectedRetainerFrequency = null;
    _selectedRetainerPayDate = null;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New client'),
              content: Form(
                key: _clientFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _clientNameController,
                        decoration: const InputDecoration(
                          labelText: 'Client name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a client name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Contract type',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
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
                              setDialogState(() {
                                _selectedContractType = entry.key;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (_selectedContractType == null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select a contract type',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _plannedBudgetController,
                        decoration: InputDecoration(
                          labelText: _selectedContractType == 'retainer'
                              ? 'Retainer amount (€)'
                              : 'Planned budget (€) (optional)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (_selectedContractType == 'retainer') {
                            if (trimmed.isEmpty) {
                              return 'Enter a retainer amount';
                            }
                            final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid amount';
                            }
                          } else if (trimmed.isNotEmpty) {
                            final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
                            if (parsed == null || parsed < 0) {
                              return 'Enter a valid budget';
                            }
                          }
                          return null;
                        },
                      ),
                      if (_selectedContractType == 'retainer') ...[
                        const SizedBox(height: 12),
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
                            setDialogState(() {
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
                              context: dialogContext,
                              initialDate: _selectedRetainerPayDate ?? now,
                              firstDate: now,
                              lastDate: DateTime(now.year + 5),
                            );
                            if (picked == null) {
                              return;
                            }
                            setDialogState(() {
                              _selectedRetainerPayDate = picked;
                            });
                          },
                        ),
                        if (_selectedRetainerPayDate == null) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Select a payment date',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactNameController,
                        decoration: const InputDecoration(
                          labelText: 'Contact name (optional)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone (optional)',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Email (optional)',
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactTelegramController,
                        decoration: const InputDecoration(
                          labelText: 'Telegram (optional)',
                          hintText: '@username',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final isValid = _clientFormKey.currentState?.validate() ?? false;
                    if (_selectedContractType == null) {
                      setDialogState(() {});
                      return;
                    }
                    if (_selectedContractType == 'retainer' && _selectedRetainerPayDate == null) {
                      setDialogState(() {});
                      return;
                    }
                    if (!isValid) {
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    _addClient();
                  },
                  child: const Text('Add client'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addClient() async {
    final contractType = _selectedContractType ?? 'project';
    final contactName = _contactNameController.text.trim();
    final contactPhone = _contactPhoneController.text.trim();
    final contactEmail = _contactEmailController.text.trim();
    final contactTelegram = _contactTelegramController.text.trim();
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

    setState(() {
      _clients.add(
        Client(
          id: _generateId(),
          name: _clientNameController.text.trim(),
          type: contractType,
          contactPerson: contactName.isEmpty ? null : contactName,
          phone: contactPhone.isEmpty ? null : contactPhone,
          email: contactEmail.isEmpty ? null : contactEmail,
          telegram: contactTelegram.isEmpty ? null : contactTelegram,
          plannedBudget: contractType == 'project' ? plannedBudget : null,
          currency: 'EUR',
          isArchived: false,
          createdAt: now,
          updatedAt: now,
          retainerSettings: retainerSettings,
        ),
      );
    });
    await _persistData();
    if (!mounted) {
      return;
    }
    _showSnackBar(context, 'Client added');
  }

  bool _isRetainerClient(Client client) {
    return client.type == 'retainer';
  }

  List<Client> _projectEligibleClients() {
    return _clients
        .where((client) => !client.isArchived && !_isRetainerClient(client))
        .toList();
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

  void _showProjectForm() {
    final eligibleClients = _projectEligibleClients();
    if (eligibleClients.isEmpty) {
      _showSnackBar(context, 'Create a project client first');
      return;
    }
    _projectNameController.clear();
    _selectedProjectClient = null;
    _selectedProjectStage = null;
    _selectedProjectDeadline = null;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New project'),
              content: Form(
                key: _projectFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedProjectClient,
                        decoration: const InputDecoration(
                          labelText: 'Client',
                        ),
                        items: eligibleClients
                            .map(
                              (client) => DropdownMenuItem(
                                value: client.name,
                                child: Text(client.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a project name';
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
                        items: _projectStageLabels.entries
                            .map(
                              (entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
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
                            context: dialogContext,
                            initialDate: _selectedProjectDeadline ?? now,
                            firstDate: now,
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked == null) {
                            return;
                          }
                          setDialogState(() {
                            _selectedProjectDeadline = picked;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final isValid = _projectFormKey.currentState?.validate() ?? false;
                    if (!isValid) {
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    _addProject();
                  },
                  child: const Text('Add project'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPaymentForm() {
    _paymentAmountController.clear();
    _selectedPaymentProjectId = null;
    _selectedPaymentKind = null;
    _selectedPaymentDueDate = null;
    _selectedPaymentPaidDate = null;
    _selectedPaymentStatus = 'planned';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final projectOptions = _projects
                .where((project) => _clientById(project.clientId)?.isArchived != true)
                .toList();
            return AlertDialog(
              title: const Text('New payment'),
              content: Form(
                key: _paymentFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
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
                          labelText: 'Payment amount (€)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a payment amount';
                          }
                          final parsed = double.tryParse(value.replaceAll(',', '.'));
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
                          setDialogState(() {
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
                          setDialogState(() {
                            _selectedPaymentStatus = value;
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
                            context: dialogContext,
                            initialDate: _selectedPaymentDueDate ?? now,
                            firstDate: DateTime(now.year - 5),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked == null) {
                            return;
                          }
                          setDialogState(() {
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
                              context: dialogContext,
                              initialDate: _selectedPaymentPaidDate ?? now,
                              firstDate: DateTime(now.year - 5),
                              lastDate: DateTime(now.year + 5),
                            );
                            if (picked == null) {
                              return;
                            }
                            setDialogState(() {
                              _selectedPaymentPaidDate = picked;
                            });
                          },
                        ),
                        if (_selectedPaymentPaidDate == null) ...[
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
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final isValid = _paymentFormKey.currentState?.validate() ?? false;
                    if (_selectedPaymentStatus == 'paid' && _selectedPaymentPaidDate == null) {
                      setDialogState(() {});
                      return;
                    }
                    if (!isValid) {
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    _addPayment();
                  },
                  child: const Text('Add payment'),
                ),
              ],
            );
          },
        );
      },
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
    await _persistData();
    if (!mounted) {
      return;
    }
    _showSnackBar(context, 'Payment added');
  }

  Future<void> _addProject() async {
    final clientName = _selectedProjectClient;
    if (clientName == null) {
      _showSnackBar(context, 'Select a client');
      return;
    }
    final client = _clients.firstWhere((item) => item.name == clientName);
    if (_isRetainerClient(client)) {
      _showSnackBar(context, 'Retainer clients cannot have projects');
      return;
    }
    final stage = _selectedProjectStage ?? 'first_meeting';
    final deadline = _selectedProjectDeadline;
    final now = DateTime.now();
    setState(() {
      _projects.add(
        Project(
          id: _generateId(),
          clientId: client.id,
          title: _projectNameController.text.trim(),
          status: stage,
          deadlineDate: deadline,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
    await _persistData();
    if (!mounted) {
      return;
    }
    _showSnackBar(context, 'Project added');
  }

  Future<void> _addProjectFromDetails(Project project) async {
    setState(() {
      _projects.add(project);
    });
    await _persistData();
  }

  Future<void> _deleteProject(Project project) async {
    setState(() {
      _projects.remove(project);
    });
    await _persistData();
  }

  Future<void> _updateProject(Project oldProject, Project updatedProject) async {
    setState(() {
      final index = _projects.indexOf(oldProject);
      if (index != -1) {
        _projects[index] = updatedProject;
      }
    });
    await _persistData();
  }

  Future<void> _updateProjectPayment(
    ProjectPayment oldPayment,
    ProjectPayment updatedPayment,
  ) async {
    setState(() {
      final index = _projectPayments.indexOf(oldPayment);
      if (index != -1) {
        _projectPayments[index] = updatedPayment;
      }
    });
    await _persistData();
  }

  Future<void> _deleteProjectPayment(ProjectPayment payment) async {
    setState(() {
      _projectPayments.remove(payment);
    });
    await _persistData();
  }

  Future<Project> _duplicateProject(Project project) async {
    final duplicated = Project(
      id: _generateId(),
      clientId: project.clientId,
      title: '${project.title} (copy)',
      status: project.status,
      deadlineDate: project.deadlineDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _addProjectFromDetails(duplicated);
    return duplicated;
  }

  Future<void> _deleteClient(Client client) async {
    setState(() {
      final index = _clients.indexWhere((item) => item.id == client.id);
      if (index != -1) {
        _clients[index] = Client(
          id: client.id,
          name: client.name,
          type: client.type,
          contactPerson: client.contactPerson,
          phone: client.phone,
          email: client.email,
          telegram: client.telegram,
          plannedBudget: client.plannedBudget,
          currency: client.currency,
          isArchived: true,
          createdAt: client.createdAt,
          updatedAt: DateTime.now(),
          retainerSettings: client.retainerSettings,
        );
      }
    });
    await _persistData();
  }

  Future<void> _openClientDetails(Client client) async {
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
          onDeleteClient: () => _deleteClient(client),
          onUpdateClient: _updateClient,
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
    setState(() {
      final index = _clients.indexWhere((client) => client.id == updatedClient.id);
      if (index != -1) {
        _clients[index] = updatedClient;
      }
    });
    await _persistData();
  }

  String _clientTypeLabel(Client client) {
    return _isRetainerClient(client) ? 'Retainer' : 'Project';
  }

  Color _clientCardColor(BuildContext context, Client client) {
    return _isRetainerClient(client)
        ? const Color(0xFFF6F2EA)
        : const Color(0xFFF1F4F6);
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
    return plannedSum == 0 ? (client.plannedBudget ?? 0) : plannedSum;
  }

  List<_UpcomingPayment> _buildUpcomingPayments(DateTime today) {
    final windowEnd = today.add(const Duration(days: 29));
    final upcoming = <_UpcomingPayment>[];

    for (final entry in _retainerUpcomingPayments(today, windowEnd)) {
      upcoming.add(entry);
    }

    for (final payment in _projectPayments) {
      if (payment.status != 'planned' || payment.dueDate == null) {
        continue;
      }
      if (!_isWithinRange(payment.dueDate!, today, windowEnd)) {
        continue;
      }
      final project = _projectById(payment.projectId);
      if (project == null || !_isActiveProject(project)) {
        continue;
      }
      final client = _clientById(project.clientId);
      if (client == null || client.isArchived) {
        continue;
      }
      upcoming.add(
        _UpcomingPayment(
          client: client.name,
          amount: payment.amount,
          date: payment.dueDate!,
          kind: _paymentKindLabels[payment.kind] ?? payment.kind,
        ),
      );
    }

    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  }

  _UpcomingPayment? _nextRetainerPayment(DateTime reference) {
    final today = _normalizeDate(reference);
    final nextDates = <_UpcomingPayment>[];
    for (final entry in _retainerUpcomingPayments(today, today.add(const Duration(days: 60)))) {
      nextDates.add(entry);
    }
    if (nextDates.isEmpty) {
      return null;
    }
    nextDates.sort((a, b) => a.date.compareTo(b.date));
    return nextDates.first;
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
          client: client.name,
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
    return _clients.where((client) => !client.isArchived).toList();
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
      return client != null && !client.isArchived && _isActiveProject(project);
    }).toList();
  }

  Set<String> _activeProjectClients(List<Project> activeProjects) {
    return activeProjects
        .map((project) => project.clientId)
        .where((id) => _clientById(id)?.type == 'project')
        .toSet();
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

  double _plannedProjectPaymentsSum() {
    return _projectPayments.where((payment) {
      if (payment.status != 'planned') {
        return false;
      }
      final project = _projectById(payment.projectId);
      if (project == null || !_isActiveProject(project)) {
        return false;
      }
      final client = _clientById(project.clientId);
      return client != null && !client.isArchived;
    }).fold<double>(0, (sum, payment) => sum + payment.amount);
  }

  double _projectPaymentsPaidThisWeek(DateTime start, DateTime end) {
    return _projectPayments.where((payment) {
      if (payment.status != 'paid' || payment.paidDate == null) {
        return false;
      }
      if (!_isWithinRange(payment.paidDate!, start, end)) {
        return false;
      }
      final project = _projectById(payment.projectId);
      if (project == null) {
        return false;
      }
      if (project.status != 'deposit_received' &&
          project.status != 'payment_received_in_full') {
        return false;
      }
      final client = _clientById(project.clientId);
      return client != null && !client.isArchived;
    }).fold<double>(0, (sum, payment) => sum + payment.amount);
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
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  List<ProjectPayment> _migrateLegacyPayments(List<dynamic> decoded) {
    final migrated = <ProjectPayment>[];
    for (final entry in decoded.whereType<Map<String, dynamic>>()) {
      final stage = entry['stage'] as String? ?? '';
      if (stage.toLowerCase().contains('retainer')) {
        continue;
      }
      final clientName = entry['client'] as String? ?? '';
      if (clientName.isEmpty) {
        continue;
      }
      final client = _clients.cast<Client?>().firstWhere(
            (item) => item?.name == clientName,
            orElse: () => null,
          );
      final project = _projects.cast<Project?>().firstWhere(
            (item) =>
                item?.clientId == client?.id || item?.clientId == clientName,
            orElse: () => null,
          );
      if (project == null) {
        continue;
      }
      final kind = switch (stage.toLowerCase()) {
        'deposit' => 'deposit',
        'milestone' => 'milestone',
        'final payment' => 'final',
        _ => 'other',
      };
      final date = DateTime.tryParse(entry['date'] as String? ?? '') ?? DateTime.now();
      migrated.add(
        ProjectPayment(
          id: _generateId(),
          projectId: project.id,
          amount: (entry['amount'] as num?)?.toDouble() ?? 0,
          kind: kind,
          status: 'paid',
          dueDate: null,
          paidDate: date,
          createdAt: date,
          updatedAt: date,
        ),
      );
    }
    return migrated;
  }

  void _showActiveProjectsSheet(List<Project> projects) {
    _showListSheet(
      title: 'Active projects',
      items: projects
          .map(
            (project) => _SheetItem(
              title: project.title,
              subtitle:
                  '${_clientNameForId(project.clientId)} • ${_projectStageLabels[project.status] ?? project.status}',
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
    final plannedPayments = _projectPayments.where((payment) {
      if (payment.status != 'planned') {
        return false;
      }
      final project = _projectById(payment.projectId);
      if (project == null || !_isActiveProject(project)) {
        return false;
      }
      final client = _clientById(project.clientId);
      return client != null && !client.isArchived;
    }).toList();

    _showListSheet(
      title: 'Budget in progress',
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Retainers next 30 days: ${_formatCurrency(_retainerScheduledSum(start, end))}'),
          Text('Planned project payments: ${_formatCurrency(_plannedProjectPaymentsSum())}'),
          const SizedBox(height: 12),
          const Text('Retainer schedule'),
        ],
      ),
      items: [
        ...retainerEntries.map(
          (entry) => _SheetItem(
            title: entry.client,
            subtitle: 'Retainer • ${_formatDate(entry.date)}',
            trailing: _formatCurrency(entry.amount),
          ),
        ),
        if (retainerEntries.isNotEmpty) const _SheetDivider(),
        ...plannedPayments.map(
          (payment) {
            final project = _projectById(payment.projectId);
            final clientName = project == null ? 'Unknown client' : _clientNameForId(project.clientId);
            return _SheetItem(
              title: project?.title ?? 'Unknown project',
              subtitle: '$clientName • ${_paymentKindLabels[payment.kind] ?? payment.kind}',
              trailing: _formatCurrency(payment.amount),
            );
          },
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
    final retainerEntries = _retainerUpcomingPayments(start, end).toList();
    final paidProjectPayments = _projectPayments.where((payment) {
      if (payment.status != 'paid' || payment.paidDate == null) {
        return false;
      }
      if (!_isWithinRange(payment.paidDate!, start, end)) {
        return false;
      }
      final project = _projectById(payment.projectId);
      if (project == null) {
        return false;
      }
      if (project.status != 'deposit_received' &&
          project.status != 'payment_received_in_full') {
        return false;
      }
      final client = _clientById(project.clientId);
      return client != null && !client.isArchived;
    }).toList();

    _showListSheet(
      title: 'Upcoming payments',
      items: [
        ...paidProjectPayments.map(
          (payment) {
            final project = _projectById(payment.projectId);
            final clientName = project == null ? 'Unknown client' : _clientNameForId(project.clientId);
            return _SheetItem(
              title: project?.title ?? 'Unknown project',
              subtitle: '$clientName • ${_paymentKindLabels[payment.kind] ?? payment.kind}',
              trailing: _formatCurrency(payment.amount),
            );
          },
        ),
        if (paidProjectPayments.isNotEmpty) const _SheetDivider(),
        ...retainerEntries.map(
          (entry) => _SheetItem(
            title: entry.client,
            subtitle: 'Retainer • ${_formatDate(entry.date)}',
            trailing: _formatCurrency(entry.amount),
          ),
        ),
      ],
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
    return '€${amount.toStringAsFixed(0)}';
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

class _UpcomingPayment {
  const _UpcomingPayment({
    required this.client,
    required this.amount,
    required this.date,
    required this.kind,
  });

  final String client;
  final double amount;
  final DateTime date;
  final String kind;
}

class _SheetItem extends StatelessWidget {
  const _SheetItem({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing == null ? null : Text(trailing!),
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

class _UpcomingRetainerPaymentCard extends StatelessWidget {
  const _UpcomingRetainerPaymentCard({
    required this.payment,
    required this.formattedAmount,
    required this.formattedDate,
  });

  final _UpcomingPayment payment;
  final String formattedAmount;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next retainer payment',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${payment.client} • $formattedDate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formattedAmount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
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
    required this.totalAmount,
    required this.cardColor,
    required this.onTap,
  });

  final Client client;
  final bool isRetainer;
  final String initials;
  final String typeLabel;
  final double totalAmount;
  final Color cardColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tagColor = isRetainer ? const Color(0xFFE7DCCA) : const Color(0xFFD9E4EC);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: tagColor,
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        typeLabel.toLowerCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
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
                    '€${totalAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
