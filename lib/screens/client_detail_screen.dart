import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/client.dart';
import '../models/payment.dart';
import '../models/project.dart';

class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({
    super.key,
    required this.client,
    required this.projects,
    required this.payments,
    required this.onDeleteClient,
    required this.onUpdateClient,
    required this.onDuplicateProject,
    required this.onUpdateProject,
    required this.onDeleteProject,
  });

  final Client client;
  final List<Project> projects;
  final List<Payment> payments;
  final Future<void> Function() onDeleteClient;
  final Future<void> Function(Client updatedClient) onUpdateClient;
  final Future<Project> Function(Project project) onDuplicateProject;
  final Future<void> Function(Project oldProject, Project updatedProject) onUpdateProject;
  final Future<void> Function(Project project) onDeleteProject;

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
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

  late List<Project> _projects;
  late List<Payment> _payments;
  late Client _client;

  @override
  void initState() {
    super.initState();
    _client = widget.client;
    _projects = List<Project>.from(widget.projects);
    _payments = List<Payment>.from(widget.payments);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final computedPayments = _buildClientPayments(normalizedNow);
    final upcomingPayments =
        computedPayments.where((payment) => payment.date.isAfter(normalizedNow)).toList();
    final pastPayments =
        computedPayments.where((payment) => !payment.date.isAfter(normalizedNow)).toList();
    final summaryParts =
        _client.project.split(' • ').where((part) => part.trim().isNotEmpty).toList();
    final contactInfo = _extractContactInfo(summaryParts);

    return Scaffold(
      appBar: AppBar(
        title: Text(_client.name),
        actions: _isRetainerClient(_client)
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit-salary') {
                      _editSalary();
                    } else if (value == 'delete') {
                      _confirmDeleteClient();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit-salary',
                      child: Text('Edit salary'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete client'),
                    ),
                  ],
                ),
              ]
            : [
                IconButton(
                  tooltip: 'Delete client',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDeleteClient,
                ),
              ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoCard(
            title: 'Client details',
            children: [
              _InfoRow(label: 'Name', value: _client.name),
              _InfoRow(label: 'Status', value: _client.status),
              _InfoRow(
                label: _isRetainerClient(_client) ? 'Salary' : 'Budget',
                value: _formatCurrency(_client.budget),
              ),
              if (!_isRetainerClient(_client))
                _InfoRow(label: 'Deadline', value: _formatDate(_client.deadline)),
              _InfoChipsRow(label: 'Summary', chips: summaryParts),
              if (contactInfo != null && contactInfo.name.isNotEmpty) ...[
                _InfoRow(label: 'Contact', value: contactInfo.name),
                ...contactInfo.details.entries.map(
                  (entry) => _InfoLinkRow(
                    label: entry.key,
                    value: entry.value,
                    onTap: () => _copyToClipboard(entry.value),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          if (!_isRetainerClient(_client)) ...[
            _InfoCard(
              title: 'Projects',
              children: _projects.isEmpty
                  ? [const Text('No projects yet.')]
                  : _projects
                      .map(
                        (project) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _ProjectRow(
                            project: project,
                            onDuplicate: () => _duplicateProject(project),
                            onUpdateStage: () => _updateProjectStage(project),
                            onDelete: () => _deleteProject(project),
                            formatCurrency: _formatCurrency,
                            formatDate: _formatDate,
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
          ],
          _InfoCard(
            title: 'Upcoming payments',
            children: upcomingPayments.isEmpty
                ? [const Text('No upcoming payments.')]
                : upcomingPayments
                    .map((payment) => _PaymentRow(payment: payment))
                    .toList(),
          ),
          const SizedBox(height: 20),
          _InfoCard(
            title: 'Payment history',
            children: pastPayments.isEmpty
                ? [const Text('No payment history yet.')]
                : pastPayments
                    .map((payment) => _PaymentRow(payment: payment))
                    .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteClient() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete client'),
        content: const Text('This will remove the client and all related projects and payments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) {
      return;
    }
    await widget.onDeleteClient();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _editSalary() async {
    final salaryController = TextEditingController(text: _client.budget.toStringAsFixed(0));
    final updated = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit salary'),
        content: TextField(
          controller: salaryController,
          decoration: const InputDecoration(labelText: 'Salary (€)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed =
                  double.tryParse(salaryController.text.trim().replaceAll(',', '.'));
              if (parsed == null || parsed <= 0) {
                return;
              }
              Navigator.of(dialogContext).pop(parsed);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (updated == null) {
      return;
    }
    final updatedClient = Client(
      name: _client.name,
      project: _updateSummarySalary(_client.project, updated),
      status: _client.status,
      budget: updated,
      deadline: _client.deadline,
    );
    await widget.onUpdateClient(updatedClient);
    if (!mounted) {
      return;
    }
    setState(() {
      _client = updatedClient;
    });
  }

  Future<void> _duplicateProject(Project project) async {
    final duplicated = await widget.onDuplicateProject(project);
    if (!mounted) {
      return;
    }
    setState(() {
      _projects.add(duplicated);
    });
  }

  Future<void> _deleteProject(Project project) async {
    await widget.onDeleteProject(project);
    if (!mounted) {
      return;
    }
    setState(() {
      _projects.remove(project);
    });
  }

  Future<void> _updateProjectStage(Project project) async {
    final depositController = TextEditingController(
      text: project.depositPercent?.toStringAsFixed(0) ?? '',
    );
    final budgetController = TextEditingController(
      text: project.amount.toStringAsFixed(0),
    );
    var selectedStage = project.stage;
    DateTime? selectedDeadline = project.nextStageDeadline;
    var showErrors = false;

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Update stage'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStage.isEmpty ? null : selectedStage,
                      decoration: const InputDecoration(
                        labelText: 'Stage',
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
                          selectedStage = value ?? selectedStage;
                        });
                      },
                    ),
                    if (showErrors && (selectedStage.isEmpty)) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Select a stage',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                    if (selectedStage == 'Renegotiating budget') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: budgetController,
                        decoration: const InputDecoration(
                          labelText: 'New budget (€)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      if (showErrors &&
                          (double.tryParse(
                                budgetController.text.trim().replaceAll(',', '.'),
                              ) ==
                              null)) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Enter a valid budget',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ],
                    if (selectedStage == 'Deposit received') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: depositController,
                        decoration: const InputDecoration(
                          labelText: 'Deposit percent (%)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      if (showErrors &&
                          (double.tryParse(
                                depositController.text.trim().replaceAll(',', '.'),
                              ) ==
                              null)) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Enter a valid percent',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ],
                    if (selectedStage != 'Payment received in full') ...[
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Deadline to next stage'),
                        subtitle: Text(
                          selectedDeadline == null
                              ? 'Select a date'
                              : _formatDate(selectedDeadline!),
                        ),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDeadline ?? now,
                            firstDate: now,
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked == null) {
                            return;
                          }
                          setDialogState(() {
                            selectedDeadline = picked;
                          });
                        },
                      ),
                      if (showErrors && selectedDeadline == null) ...[
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final depositValue = double.tryParse(
                      depositController.text.trim().replaceAll(',', '.'),
                    );
                    final budgetValue = double.tryParse(
                      budgetController.text.trim().replaceAll(',', '.'),
                    );
                    final hasDeadline =
                        selectedStage == 'Payment received in full' || selectedDeadline != null;
                    final hasValidDeposit =
                        selectedStage != 'Deposit received' || depositValue != null;
                    final hasValidBudget =
                        selectedStage != 'Renegotiating budget' || budgetValue != null;
                    if (selectedStage.isEmpty || !hasDeadline || !hasValidDeposit || !hasValidBudget) {
                      setDialogState(() {
                        showErrors = true;
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldUpdate != true) {
      return;
    }

    final updatedAmount = selectedStage == 'Renegotiating budget'
        ? double.tryParse(budgetController.text.trim().replaceAll(',', '.')) ??
            project.amount
        : project.amount;
    final updatedDeposit = selectedStage == 'Deposit received'
        ? double.tryParse(depositController.text.trim().replaceAll(',', '.'))
        : null;
    final updatedProject = Project(
      clientName: project.clientName,
      name: project.name,
      amount: updatedAmount,
      stage: selectedStage,
      depositPercent: updatedDeposit,
      nextStageDeadline: selectedStage == 'Payment received in full'
          ? project.nextStageDeadline
          : selectedDeadline ?? project.nextStageDeadline,
    );

    await widget.onUpdateProject(project, updatedProject);
    if (!mounted) {
      return;
    }
    setState(() {
      final index = _projects.indexOf(project);
      if (index != -1) {
        _projects[index] = updatedProject;
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double amount) {
    return '€${amount.toStringAsFixed(0)}';
  }

  bool _isRetainerClient(Client client) {
    return client.project.toLowerCase().startsWith('retainer');
  }

  List<Payment> _buildClientPayments(DateTime now) {
    final combined = List<Payment>.from(_payments);
    for (final project in _projects) {
      final depositAmount = _depositAmount(project);
      if (depositAmount > 0) {
        combined.add(
          Payment(
            client: project.clientName,
            amount: depositAmount,
            date: now,
            stage: 'Deposit received',
          ),
        );
      }
    }
    combined.sort((a, b) => a.date.compareTo(b.date));
    return combined;
  }

  double _depositAmount(Project project) {
    if (project.stage != 'Deposit received' || project.depositPercent == null) {
      return 0;
    }
    return project.amount * (project.depositPercent! / 100);
  }

  _ContactInfo? _extractContactInfo(List<String> summaryParts) {
    final contactPart = summaryParts.firstWhere(
      (part) =>
          part.contains('Phone:') || part.contains('Email:') || part.contains('Telegram:'),
      orElse: () => '',
    );
    if (contactPart.isEmpty) {
      return null;
    }
    final match = RegExp(r'^(.*)\s*\((.*)\)$').firstMatch(contactPart);
    final name = match?.group(1)?.trim() ?? '';
    final detailsRaw = match?.group(2)?.trim() ?? contactPart;
    final details = <String, String>{};
    for (final segment in detailsRaw.split(',')) {
      final trimmed = segment.trim();
      if (trimmed.startsWith('Phone:')) {
        details['Phone'] = trimmed.replaceFirst('Phone:', '').trim();
      } else if (trimmed.startsWith('Email:')) {
        details['Email'] = trimmed.replaceFirst('Email:', '').trim();
      } else if (trimmed.startsWith('Telegram:')) {
        details['Telegram'] = trimmed.replaceFirst('Telegram:', '').trim();
      }
    }
    return _ContactInfo(name: name, details: details);
  }

  String _updateSummarySalary(String summary, double salary) {
    final salaryLabel = _formatCurrency(salary);
    return summary.replaceFirst(RegExp(r'€\d+'), salaryLabel);
  }

  Future<void> _copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied $value')),
    );
  }
}

class _ContactInfo {
  const _ContactInfo({required this.name, required this.details});

  final String name;
  final Map<String, String> details;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChipsRow extends StatelessWidget {
  const _InfoChipsRow({required this.label, required this.chips});

  final String label;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: chips
                    .map(
                      (chip) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(chip),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLinkRow extends StatelessWidget {
  const _InfoLinkRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({
    required this.project,
    required this.onDuplicate,
    required this.onUpdateStage,
    required this.onDelete,
    required this.formatCurrency,
    required this.formatDate,
  });

  final Project project;
  final VoidCallback onDuplicate;
  final VoidCallback onUpdateStage;
  final VoidCallback onDelete;
  final String Function(double) formatCurrency;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                project.stage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatCurrency(project.amount)} • ${formatDate(project.nextStageDeadline)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'duplicate') {
              onDuplicate();
            } else if (value == 'update-stage') {
              onUpdateStage();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'update-stage',
              child: Text('Change stage'),
            ),
            PopupMenuItem(
              value: 'duplicate',
              child: Text('Duplicate'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.stage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.client,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '€${payment.amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
