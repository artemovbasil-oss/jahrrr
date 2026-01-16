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
  String? _selectedWorkType;
  late final Future<PackageInfo> _packageInfoFuture;
  final GlobalKey<FormState> _clientFormKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientTimelineController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactMethodController = TextEditingController();

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
    _clientTimelineController.dispose();
    _contactNameController.dispose();
    _contactMethodController.dispose();
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
    _clientTimelineController.clear();
    _contactNameController.clear();
    _contactMethodController.clear();
    _selectedWorkType = null;

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
                      DropdownButtonFormField<String>(
                        value: _selectedWorkType,
                        decoration: const InputDecoration(
                          labelText: 'Work type (optional)',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Project',
                            child: Text('Project'),
                          ),
                          DropdownMenuItem(
                            value: 'Retainer',
                            child: Text('Retainer'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedWorkType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _clientTimelineController,
                        decoration: const InputDecoration(
                          labelText: 'Planned collaboration (optional)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactNameController,
                        decoration: const InputDecoration(
                          labelText: 'Contact name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a contact name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactMethodController,
                        decoration: const InputDecoration(
                          labelText: 'Contact method',
                          hintText: 'Email, phone, or messenger',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a contact method';
                          }
                          return null;
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
                    final isValid = _clientFormKey.currentState?.validate() ?? false;
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
    final workType = _clientWorkTypeLabel(_selectedWorkType);
    final timeline = _clientTimelineController.text.trim();
    final contactName = _contactNameController.text.trim();
    final contactMethod = _contactMethodController.text.trim();
    final projectSummary = _buildProjectSummary(
      workType: workType,
      timeline: timeline,
      contactName: contactName,
      contactMethod: contactMethod,
    );

    setState(() {
      _clients.add(
        Client(
          name: _clientNameController.text.trim(),
          project: projectSummary,
          status: 'New',
          budget: 0,
          deadline: DateTime.now().add(const Duration(days: 90)),
        ),
      );
    });
    _showSnackBar(context, 'Client added');
  }

  String _buildProjectSummary({
    required String workType,
    required String timeline,
    required String contactName,
    required String contactMethod,
  }) {
    final timelineLabel = timeline.isEmpty ? 'Timeline TBD' : timeline;
    return '$workType • $timelineLabel • $contactName ($contactMethod)';
  }

  String _clientWorkTypeLabel(String? workType) {
    return workType == null || workType.isEmpty ? 'General' : workType;
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
