import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/client.dart';
import '../models/milestone.dart';
import '../models/payment.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _selectedClientStatus;
  String? _selectedContractType;
  late final Future<PackageInfo> _packageInfoFuture;
  final GlobalKey<FormState> _clientFormKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _plannedBudgetController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactTelegramController = TextEditingController();

  final List<Client> _clients = [
        Client(
          name: 'Studio Puncto',
          project: 'Brand identity refresh',
          status: 'In production',
          budget: 4800,
          deadline: DateTime(2024, 11, 14),
        ),
        Client(
          name: 'Lunar Cafe',
          project: 'Menu and packaging',
          status: 'Concept',
          budget: 2100,
          deadline: DateTime(2024, 10, 30),
        ),
        Client(
          name: 'Nova Interiors',
          project: 'Digital presentation',
          status: 'Finalization',
          budget: 3200,
          deadline: DateTime(2024, 11, 22),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _plannedBudgetController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _contactTelegramController.dispose();
    super.dispose();
  }

  List<Milestone> get milestones => [
        Milestone(
          title: 'Moodboard approval',
          client: 'Studio Puncto',
          dueDate: DateTime(2024, 10, 18),
          progress: 0.72,
        ),
        Milestone(
          title: 'Landing page prototype',
          client: 'Nova Interiors',
          dueDate: DateTime(2024, 10, 24),
          progress: 0.48,
        ),
      ];

  List<Payment> get payments => [
        Payment(
          client: 'Lunar Cafe',
          amount: 900,
          date: DateTime(2024, 10, 12),
          stage: 'Deposit',
        ),
        Payment(
          client: 'Studio Puncto',
          amount: 1400,
          date: DateTime(2024, 10, 8),
          stage: 'Sprint 1',
        ),
        Payment(
          client: 'Nova Interiors',
          amount: 700,
          date: DateTime(2024, 10, 5),
          stage: 'Research',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final referenceDate = DateTime(2024, 10, 1);
    final activeProjects = _clients.length;
    final totalBudget = _clients.fold<double>(0, (sum, client) => sum + client.budget);
    final deadlinesThisWeek =
        milestones.where((milestone) => _isWithinDays(referenceDate, milestone.dueDate, 7)).length;
    final upcomingPayments = payments
        .where((payment) => _isWithinDays(referenceDate, payment.date, 7))
        .fold<double>(0, (sum, payment) => sum + payment.amount);
    final clientStatuses = _clients.map((client) => client.status).toSet().toList()..sort();
    final visibleClients = _selectedClientStatus == null
        ? _clients
        : _clients.where((client) => client.status == _selectedClientStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
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
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
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
                color: Color(0xFF4F46E5),
                onTap: () => _showSnackBar(context, 'Opening active projects'),
              ),
              StatCard(
                title: 'Budget in progress',
                value: _formatCurrency(totalBudget),
                subtitle: 'Across ${_clients.length} projects',
                color: Color(0xFF10B981),
                onTap: () => _showSnackBar(context, 'Reviewing budget in progress'),
              ),
              StatCard(
                title: 'Deadlines this week',
                value: deadlinesThisWeek.toString(),
                subtitle: 'Next 7 days',
                color: Color(0xFFF59E0B),
                onTap: () => _showSnackBar(context, 'Checking weekly deadlines'),
              ),
              StatCard(
                title: 'Upcoming payments',
                value: _formatCurrency(upcomingPayments),
                subtitle: 'Next 7 days',
                color: Color(0xFFEC4899),
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
          ...milestones.map(
            (milestone) => Card(
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
                            milestone.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Text(
                          _formatDate(milestone.dueDate),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      milestone.client,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: LinearProgressIndicator(
                        value: milestone.progress,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Payments',
            actionLabel: 'Export',
            onActionPressed: () => _showSnackBar(context, 'Exporting payments'),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ...payments.map(
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
                        'Total for October',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '€3 000',
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
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Clients',
            actionLabel: 'Add',
            onActionPressed: _showClientForm,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _selectedClientStatus == null,
                onSelected: (_) => _updateClientStatusFilter(null),
              ),
              ...clientStatuses.map(
                (status) => ChoiceChip(
                  label: Text(status),
                  selected: _selectedClientStatus == status,
                  onSelected: (_) => _updateClientStatusFilter(status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...visibleClients.map(
            (client) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                title: Text(client.name),
                subtitle: Text(client.project),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '€${client.budget.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.status,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateMenu,
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                        decoration: const InputDecoration(
                          labelText: 'Planned budget (€)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a planned budget';
                          }
                          final parsed = double.tryParse(value.replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid budget';
                          }
                          return null;
                        },
                      ),
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

  void _addClient() {
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
    });
    _showSnackBar(context, 'Client added');
  }

  String _buildProjectSummary({
    required String contractType,
    required String contactName,
    required String contactPhone,
    required String contactEmail,
    required String contactTelegram,
  }) {
    final contactLine = _buildContactLine(
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      contactTelegram: contactTelegram,
    );
    return '$contractType • $contactLine';
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
      return 'Contact TBD';
    }
    if (contactName.isEmpty) {
      return details.join(', ');
    }
    if (details.isEmpty) {
      return contactName;
    }
    return '$contactName (${details.join(', ')})';
  }

  void _showCreateMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add_outlined),
                title: const Text('New client'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _showClientForm();
                },
              ),
              ListTile(
                leading: const Icon(Icons.work_outline),
                title: const Text('New project'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  if (_clients.isEmpty) {
                    _showSnackBar(context, 'Create a client first');
                    return;
                  }
                  _showSnackBar(context, 'Select a client to create a project');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateClientStatusFilter(String? status) {
    setState(() {
      _selectedClientStatus = status;
    });
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
}
