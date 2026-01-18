import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/client.dart';
import '../models/payment.dart';
import '../models/project.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import 'client_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const List<String> _projectStages = [
    'First meeting',
    'Deposit received',
    'In progress',
    'Awaiting feedback',
    'Returned for revision',
    'Renegotiating budget',
    'Project on hold',
    'Payment received in full',
  ];
  static const List<String> _paymentStages = [
    'Retainer',
    'Deposit',
    'Milestone',
    'Final payment',
  ];
  static const List<String> _retainerFrequencies = [
    'Monthly',
    'Twice a month',
  ];
  static const String _retainerPaymentStage = 'Retainer';

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
  final TextEditingController _projectAmountController = TextEditingController();
  final TextEditingController _depositPercentController = TextEditingController();
  final TextEditingController _paymentAmountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedProjectClient;
  String? _selectedProjectStage;
  String? _selectedRetainerFrequency;
  DateTime? _selectedProjectDeadline;
  DateTime? _selectedRetainerPayDate;
  String? _selectedPaymentClient;
  String? _selectedPaymentStage;
  DateTime? _selectedPaymentDate;
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
    _projectAmountController.dispose();
    _depositPercentController.dispose();
    _paymentAmountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  final List<Payment> _payments = [];

  @override
  Widget build(BuildContext context) {
    final referenceDate = DateTime(2024, 10, 1);
    final now = DateTime.now();
    final activeProjects = _isLoading ? 0 : _projects.length;
    final double totalBudget =
        _isLoading ? 0 : _clients.fold<double>(0, (sum, client) => sum + client.budget);
    final deadlinesThisWeek =
        _isLoading
            ? 0
            : _projects
                .where((project) => _isWithinDays(referenceDate, project.nextStageDeadline, 7))
                .length;
    final upcomingPaymentItems =
        _isLoading ? <Payment>[] : _buildUpcomingPayments(now);
    final double upcomingPayments = _isLoading
        ? 0
        : upcomingPaymentItems.fold<double>(0, (sum, payment) => sum + payment.amount);
    final clientStatuses = _projectStages;
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filteredProjects = normalizedQuery.isEmpty
        ? _projects
        : _projects
            .where(
              (project) =>
                  project.name.toLowerCase().contains(normalizedQuery) ||
                  project.clientName.toLowerCase().contains(normalizedQuery),
            )
            .toList();
    final visibleClients = _selectedClientStatus == null
        ? _clients
        : _clients
            .where(
              (client) => _projects.any(
                (project) =>
                    project.clientName == client.name &&
                    project.stage == _selectedClientStatus,
              ),
            )
            .toList();
    final filteredClients = normalizedQuery.isEmpty
        ? visibleClients
        : visibleClients
            .where(
              (client) =>
                  client.name.toLowerCase().contains(normalizedQuery) ||
                  client.project.toLowerCase().contains(normalizedQuery),
            )
            .toList();
    final filteredPayments = normalizedQuery.isEmpty
        ? upcomingPaymentItems
        : upcomingPaymentItems
            .where(
              (payment) =>
                  payment.client.toLowerCase().contains(normalizedQuery) ||
                  payment.stage.toLowerCase().contains(normalizedQuery),
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
                                  project.name,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Text(
                                _formatDate(project.nextStageDeadline),
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            project.clientName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project.stage,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: LinearProgressIndicator(
                              value: _projectStageProgress(project.stage),
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _projectStageColor(project.stage),
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
                          subtitle: Text('${payment.stage} • ${_formatDate(payment.date)}'),
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
                value: activeProjects.toString(),
                subtitle: 'Across ${_clients.length} clients',
                color: Color(0xFF8CB7C9),
                onTap: () => _showSnackBar(context, 'Opening active projects'),
              ),
              StatCard(
                title: 'Budget in progress',
                value: _formatCurrency(totalBudget),
                subtitle: 'Across ${_clients.length} projects',
                color: Color(0xFF7AA37C),
                onTap: () => _showSnackBar(context, 'Reviewing budget in progress'),
              ),
              StatCard(
                title: 'Deadlines this week',
                value: deadlinesThisWeek.toString(),
                subtitle: 'Next 7 days',
                color: Color(0xFFF47A64),
                onTap: () => _showSnackBar(context, 'Checking weekly deadlines'),
              ),
              StatCard(
                title: 'Upcoming payments',
                value: _formatCurrency(upcomingPayments),
                subtitle: 'Next 7 days',
                color: Color(0xFFB8432D),
                onTap: () => _showSnackBar(context, 'Reviewing upcoming payments'),
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
              if (_clients.isEmpty) {
                _showSnackBar(context, 'Create a client first');
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
                ),
                const SizedBox(width: 8),
                ...clientStatuses.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: _selectedClientStatus == status,
                      onSelected: (_) => _updateClientStatusFilter(status),
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
      final paymentsData = prefs.getString('payments');
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
        _payments
          ..clear()
          ..addAll(
            decoded
                .whereType<Map<String, dynamic>>()
                .map(Payment.fromJson),
          );
      }
    } catch (_) {
      _clients.clear();
      _projects.clear();
      _payments.clear();
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
      'payments',
      jsonEncode(_payments.map((payment) => payment.toJson()).toList()),
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
                        children: ['Project', 'Retainer'].map((type) {
                          return ChoiceChip(
                            label: Text(type),
                            selected: _selectedContractType == type,
                            onSelected: (_) {
                              setDialogState(() {
                                _selectedContractType = type;
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
                          labelText: _selectedContractType == 'Retainer'
                              ? 'Retainer amount (€)'
                              : 'Planned budget (€)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return _selectedContractType == 'Retainer'
                                ? 'Enter a retainer amount'
                                : 'Enter a planned budget';
                          }
                          final parsed = double.tryParse(value.replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid budget';
                          }
                          return null;
                        },
                      ),
                      if (_selectedContractType == 'Retainer') ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedRetainerFrequency,
                          decoration: const InputDecoration(
                            labelText: 'Payment frequency',
                          ),
                          items: _retainerFrequencies
                              .map(
                                (frequency) => DropdownMenuItem(
                                  value: frequency,
                                  child: Text(frequency),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              _selectedRetainerFrequency = value;
                            });
                          },
                          validator: (value) {
                            if (_selectedContractType != 'Retainer') {
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
                    if (_selectedContractType == 'Retainer' && _selectedRetainerPayDate == null) {
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
    final contractType = _selectedContractType ?? 'Project';
    final contactName = _contactNameController.text.trim();
    final contactPhone = _contactPhoneController.text.trim();
    final contactEmail = _contactEmailController.text.trim();
    final contactTelegram = _contactTelegramController.text.trim();
    final projectSummary = _buildProjectSummary(
      contractType: contractType,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      contactTelegram: contactTelegram,
      budget: double.tryParse(_plannedBudgetController.text.trim().replaceAll(',', '.')) ?? 0,
      retainerFrequency: _selectedRetainerFrequency ?? '',
      retainerPayDate: _selectedRetainerPayDate,
    );
    final plannedBudget =
        double.tryParse(_plannedBudgetController.text.trim().replaceAll(',', '.')) ?? 0;

    setState(() {
      _clients.add(
        Client(
          name: _clientNameController.text.trim(),
          project: projectSummary,
          status: 'New',
          budget: plannedBudget,
          deadline: DateTime.now().add(const Duration(days: 90)),
        ),
      );
      if (contractType == 'Retainer') {
        _addRetainerPayments(
          clientName: _clientNameController.text.trim(),
          amount: plannedBudget,
          frequency: _selectedRetainerFrequency ?? _retainerFrequencies.first,
          nextPayDate: _selectedRetainerPayDate ?? DateTime.now(),
        );
      }
    });
    await _persistData();
    if (!mounted) {
      return;
    }
    _showSnackBar(context, 'Client added');
  }

  String _buildProjectSummary({
    required String contractType,
    required String contactName,
    required String contactPhone,
    required String contactEmail,
    required String contactTelegram,
    required double budget,
    required String retainerFrequency,
    required DateTime? retainerPayDate,
  }) {
    final contactLine = _buildContactLine(
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      contactTelegram: contactTelegram,
    );
    final summaryParts = <String>[
      contractType,
      if (contractType == 'Retainer')
        '${_formatCurrency(budget)} • ${retainerFrequency.isEmpty ? 'Recurring' : retainerFrequency}'
            '${retainerPayDate == null ? '' : ' • ${_formatDate(retainerPayDate)}'}',
    ];
    if (contactLine.isNotEmpty) {
      summaryParts.add(contactLine);
    }
    return summaryParts.join(' • ');
  }

  String _buildContactLine({
    required String contactName,
    required String contactPhone,
    required String contactEmail,
    required String contactTelegram,
  }) {
    final details = [
      if (contactPhone.isNotEmpty) 'Phone: $contactPhone',
      if (contactEmail.isNotEmpty) 'Email: $contactEmail',
      if (contactTelegram.isNotEmpty) 'Telegram: $contactTelegram',
    ];
    if (contactName.isEmpty && details.isEmpty) {
      return '';
    }
    if (contactName.isEmpty) {
      return details.join(', ');
    }
    if (details.isEmpty) {
      return contactName;
    }
    return '$contactName (${details.join(', ')})';
  }

  bool _isRetainerClient(Client client) {
    return client.project.toLowerCase().startsWith('retainer');
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
      _showSnackBar(context, 'Retainer clients cannot have projects');
      return;
    }
    _showProjectForm();
  }

  void _showProjectForm() {
    final eligibleClients = _projectEligibleClients();
    if (eligibleClients.isEmpty) {
      _showSnackBar(context, 'Retainer clients cannot have projects');
      return;
    }
    _projectNameController.clear();
    _projectAmountController.clear();
    _depositPercentController.clear();
    _selectedProjectClient = null;
    _selectedProjectStage = null;
    _selectedProjectDeadline = null;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final selectedClient = _selectedProjectClient == null
                ? null
                : _clients.firstWhere((client) => client.name == _selectedProjectClient);
            final isFirstProject = selectedClient == null
                ? false
                : _projects.where((project) => project.clientName == selectedClient.name).isEmpty;

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
                            if (value == null) {
                              _projectAmountController.clear();
                              return;
                            }
                            final client = _clients.firstWhere((c) => c.name == value);
                            final hasProjects = _projects
                                .any((project) => project.clientName == client.name);
                            if (hasProjects) {
                              _projectAmountController.clear();
                            } else {
                              _projectAmountController.text =
                                  client.budget == 0 ? '' : client.budget.toStringAsFixed(0);
                            }
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
                      TextFormField(
                        controller: _projectAmountController,
                        decoration: InputDecoration(
                          labelText: isFirstProject
                              ? 'Project amount (€) (prefilled)'
                              : 'Project amount (€)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (!isFirstProject && (value == null || value.trim().isEmpty)) {
                            return 'Enter a project amount';
                          }
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a project amount';
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
                        value: _selectedProjectStage,
                        decoration: const InputDecoration(
                          labelText: 'Project stage',
                        ),
                        items: _projectStages
                            .map(
                              (stage) => DropdownMenuItem(
                                value: stage,
                                child: Text(stage),
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
                      if (_selectedProjectStage == 'Deposit received') ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _depositPercentController,
                          decoration: const InputDecoration(
                            labelText: 'Deposit percent (%)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (_selectedProjectStage != 'Deposit received') {
                              return null;
                            }
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter a deposit percent';
                            }
                            final parsed = double.tryParse(value.replaceAll(',', '.'));
                            if (parsed == null || parsed <= 0 || parsed > 100) {
                              return 'Enter a valid percent';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Deadline to next stage'),
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
                      if (_selectedProjectDeadline == null) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select a deadline',
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final isValid = _projectFormKey.currentState?.validate() ?? false;
                    if (_selectedProjectDeadline == null) {
                      setDialogState(() {});
                      return;
                    }
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
    _selectedPaymentClient = null;
    _selectedPaymentStage = null;
    _selectedPaymentDate = null;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New payment'),
              content: Form(
                key: _paymentFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentClient,
                        decoration: const InputDecoration(
                          labelText: 'Client',
                        ),
                        items: _clients
                            .map(
                              (client) => DropdownMenuItem(
                                value: client.name,
                                child: Text(client.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedPaymentClient = value;
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
                        value: _selectedPaymentStage,
                        decoration: const InputDecoration(
                          labelText: 'Payment stage',
                        ),
                        items: _paymentStages
                            .map(
                              (stage) => DropdownMenuItem(
                                value: stage,
                                child: Text(stage),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedPaymentStage = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Select a payment stage';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Payment date'),
                        subtitle: Text(
                          _selectedPaymentDate == null
                              ? 'Select a date'
                              : _formatDate(_selectedPaymentDate!),
                        ),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: _selectedPaymentDate ?? now,
                            firstDate: DateTime(now.year - 5),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked == null) {
                            return;
                          }
                          setDialogState(() {
                            _selectedPaymentDate = picked;
                          });
                        },
                      ),
                      if (_selectedPaymentDate == null) ...[
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
                    if (_selectedPaymentDate == null) {
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
    final clientName = _selectedPaymentClient;
    if (clientName == null) {
      _showSnackBar(context, 'Select a client');
      return;
    }
    final amount =
        double.tryParse(_paymentAmountController.text.trim().replaceAll(',', '.')) ?? 0;
    final stage = _selectedPaymentStage ?? _paymentStages.first;
    final date = _selectedPaymentDate ?? DateTime.now();

    setState(() {
      _payments.add(
        Payment(
          client: clientName,
          amount: amount,
          date: date,
          stage: stage,
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
    final amount =
        double.tryParse(_projectAmountController.text.trim().replaceAll(',', '.')) ?? 0;
    final stage = _selectedProjectStage ?? 'First meeting';
    final depositPercent = _selectedProjectStage == 'Deposit received'
        ? double.tryParse(_depositPercentController.text.trim().replaceAll(',', '.'))
        : null;
    final deadline = _selectedProjectDeadline ?? DateTime.now();
    setState(() {
      _projects.add(
        Project(
          clientName: clientName,
          name: _projectNameController.text.trim(),
          amount: amount,
          stage: stage,
          depositPercent: depositPercent,
          nextStageDeadline: deadline,
        ),
      );
      _syncClientTotals(clientName);
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
      _syncClientTotals(project.clientName);
    });
    await _persistData();
  }

  Future<void> _deleteProject(Project project) async {
    setState(() {
      _projects.remove(project);
      _syncClientTotals(project.clientName);
    });
    await _persistData();
  }

  Future<void> _updateProject(Project oldProject, Project updatedProject) async {
    setState(() {
      final index = _projects.indexOf(oldProject);
      if (index != -1) {
        _projects[index] = updatedProject;
      }
      _syncClientTotals(updatedProject.clientName);
    });
    await _persistData();
  }

  Future<Project> _duplicateProject(Project project) async {
    final duplicated = Project(
      clientName: project.clientName,
      name: '${project.name} (copy)',
      amount: project.amount,
      stage: project.stage,
      depositPercent: project.depositPercent,
      nextStageDeadline: project.nextStageDeadline,
    );
    await _addProjectFromDetails(duplicated);
    return duplicated;
  }

  Future<void> _deleteClient(Client client) async {
    setState(() {
      _clients.removeWhere((item) => item.name == client.name);
      _projects.removeWhere((item) => item.clientName == client.name);
      _payments.removeWhere((item) => item.client == client.name);
    });
    await _persistData();
  }

  void _syncClientTotals(String clientName) {
    final clientIndex = _clients.indexWhere((client) => client.name == clientName);
    if (clientIndex == -1) {
      return;
    }
    final clientProjects = _projects.where((project) => project.clientName == clientName).toList();
    final budgetTotal =
        clientProjects.fold<double>(0, (sum, project) => sum + project.amount);
    final latestStage =
        clientProjects.isEmpty ? 'New' : clientProjects.last.stage;
    final client = _clients[clientIndex];
    final deadline = clientProjects.isEmpty
        ? client.deadline
        : clientProjects.last.nextStageDeadline;
    _clients[clientIndex] = Client(
      name: client.name,
      project: client.project,
      status: latestStage,
      budget: budgetTotal,
      deadline: deadline,
    );
  }

  Future<void> _openClientDetails(Client client) async {
    final clientProjects =
        _projects.where((project) => project.clientName == client.name).toList();
    final clientPayments =
        _payments.where((payment) => payment.client == client.name).toList();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClientDetailScreen(
          client: client,
          projects: clientProjects,
          payments: clientPayments,
          onDeleteClient: () => _deleteClient(client),
          onUpdateClient: _updateClient,
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
      final index = _clients.indexWhere((client) => client.name == updatedClient.name);
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
      return client.budget;
    }
    final projectsTotal = _projects
        .where((project) => project.clientName == client.name)
        .fold<double>(0, (sum, project) => sum + project.amount);
    return projectsTotal == 0 ? client.budget : projectsTotal;
  }

  List<Payment> _buildUpcomingPayments(DateTime now) {
    final windowEnd = now.add(const Duration(days: 30));
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final upcoming = <Payment>[];

    upcoming.addAll(
      _payments.where(
        (payment) =>
            payment.stage == _retainerPaymentStage &&
            !payment.date.isBefore(normalizedNow) &&
            !payment.date.isAfter(windowEnd),
      ),
    );

    for (final project in _projects) {
      final depositAmount = _depositAmount(project);
      if (depositAmount > 0) {
        upcoming.add(
          Payment(
            client: project.clientName,
            amount: depositAmount,
            date: normalizedNow,
            stage: 'Deposit received',
          ),
        );
      }
      if (!_isWithinDays(normalizedNow, project.nextStageDeadline, 30)) {
        continue;
      }
      final remaining = (project.amount - depositAmount).clamp(0, project.amount).toDouble();
      upcoming.add(
        Payment(
          client: project.clientName,
          amount: remaining,
          date: project.nextStageDeadline,
          stage: project.stage,
        ),
      );
    }

    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  }

  void _addRetainerPayments({
    required String clientName,
    required double amount,
    required String frequency,
    required DateTime nextPayDate,
  }) {
    final paymentAmount = frequency == 'Twice a month' ? amount / 2 : amount;
    final paymentDates = <DateTime>[nextPayDate];
    if (frequency == 'Twice a month') {
      paymentDates.add(nextPayDate.add(const Duration(days: 14)));
    }
    for (final date in paymentDates) {
      _payments.add(
        Payment(
          client: clientName,
          amount: paymentAmount,
          date: date,
          stage: _retainerPaymentStage,
        ),
      );
    }
  }

  double _depositAmount(Project project) {
    if (project.stage != 'Deposit received' || project.depositPercent == null) {
      return 0;
    }
    return project.amount * (project.depositPercent! / 100);
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  bool _isWithinDays(DateTime reference, DateTime date, int days) {
    final normalizedReference = DateTime(reference.year, reference.month, reference.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final difference = normalizedDate.difference(normalizedReference).inDays;
    return difference >= 0 && difference <= days;
  }

  String _formatCurrency(double amount) {
    return '€${amount.toStringAsFixed(0)}';
  }

  double _projectStageProgress(String stage) {
    switch (stage) {
      case 'First meeting':
        return 0.1;
      case 'Deposit received':
        return 0.2;
      case 'In progress':
        return 0.35;
      case 'Awaiting feedback':
        return 0.5;
      case 'Returned for revision':
        return 0.55;
      case 'Renegotiating budget':
        return 0.6;
      case 'Project on hold':
        return 0.6;
      case 'Payment received in full':
        return 1.0;
      default:
        return 0.0;
    }
  }

  Color _projectStageColor(String stage) {
    switch (stage) {
      case 'Awaiting feedback':
        return const Color(0xFFF47A64);
      case 'Returned for revision':
        return const Color(0xFFB8432D);
      case 'Project on hold':
        return const Color(0xFF1F1C1B);
      default:
        return const Color(0xFF7AA37C);
    }
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
