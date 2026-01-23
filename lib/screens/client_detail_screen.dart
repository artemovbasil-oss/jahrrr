import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/client.dart';
import '../models/project.dart';
import '../models/project_payment.dart';
import '../models/retainer_settings.dart';
import '../widgets/skeleton.dart';

class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({
    super.key,
    required this.client,
    required this.projects,
    required this.payments,
    this.openRetainerSettings = false,
    this.isLoading = false,
    required this.onDeleteClient,
    required this.onUpdateClient,
    required this.onDuplicateClient,
    required this.onUpdatePayment,
    required this.onDeletePayment,
    required this.onDuplicateProject,
    required this.onUpdateProject,
    required this.onDeleteProject,
  });

  final Client client;
  final List<Project> projects;
  final List<ProjectPayment> payments;
  final bool openRetainerSettings;
  final bool isLoading;
  final Future<void> Function() onDeleteClient;
  final Future<void> Function(Client updatedClient) onUpdateClient;
  final Future<Client> Function(
    Client client,
    String newName,
    bool copyWithAllSettings,
  ) onDuplicateClient;
  final Future<void> Function(ProjectPayment oldPayment, ProjectPayment updatedPayment)
      onUpdatePayment;
  final Future<void> Function(ProjectPayment payment) onDeletePayment;
  final Future<Project> Function(Project project, String newTitle, bool copyWithAllSettings)
      onDuplicateProject;
  final Future<void> Function(Project oldProject, Project updatedProject) onUpdateProject;
  final Future<void> Function(Project project) onDeleteProject;

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {

  late List<Project> _projects;
  late List<ProjectPayment> _payments;
  late Client _client;

  @override
  void initState() {
    super.initState();
    _client = widget.client;
    _projects = List<Project>.from(widget.projects);
    _payments = List<ProjectPayment>.from(widget.payments);
    if (widget.openRetainerSettings && _isRetainerClient(_client)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _editClient();
      });
    }
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
    final summaryParts = _buildSummaryChips();
    final visibleProjects = _projects.toList();
    final isLoading = widget.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_client.name),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              if (value == 'edit') {
                _editClient();
              } else if (value == 'delete') {
                _confirmDeleteClient();
              } else if (value == 'duplicate') {
                _duplicateClient();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: Text('Duplicate'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoCard(
            title: 'Client details',
            children: isLoading
                ? _buildLoadingDetails()
                : [
                    _InfoRow(label: 'Name', value: _client.name),
                    _InfoRow(
                      label: 'Type',
                      value: _isRetainerClient(_client) ? 'Retainer' : 'Project',
                    ),
                    if (_isRetainerClient(_client))
                      _InfoRow(
                        label: 'Retainer amount',
                        value: _formatCurrency(_client.retainerSettings?.amount ?? 0),
                      ),
                    if (!_isRetainerClient(_client))
                      _InfoRow(
                        label: 'Planned budget',
                        value: _formatCurrency(_client.plannedBudget ?? 0),
                      ),
                    if (summaryParts.isNotEmpty)
                      _InfoChipsRow(label: 'Summary', chips: summaryParts),
                    if (_client.contactPerson != null && _client.contactPerson!.isNotEmpty)
                      _InfoRow(label: 'Contact', value: _client.contactPerson!),
                    if (_client.phone != null && _client.phone!.isNotEmpty)
                      _InfoLinkRow(
                        label: 'Phone',
                        value: _client.phone!,
                        onTap: () => _copyToClipboard(_client.phone!),
                      ),
                    if (_client.email != null && _client.email!.isNotEmpty)
                      _InfoLinkRow(
                        label: 'Email',
                        value: _client.email!,
                        onTap: () => _copyToClipboard(_client.email!),
                      ),
                    if (_client.telegram != null && _client.telegram!.isNotEmpty)
                      _InfoLinkRow(
                        label: 'Telegram',
                        value: _client.telegram!,
                        onTap: () => _copyToClipboard(_client.telegram!),
                      ),
                  ],
          ),
          const SizedBox(height: 20),
          if (!_isRetainerClient(_client)) ...[
            _InfoCard(
              title: 'Projects',
              children: isLoading
                  ? _buildLoadingProjects()
                  : visibleProjects.isEmpty
                      ? [const Text('No projects yet.')]
                      : visibleProjects
                          .map(
                            (project) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: _ProjectRow(
                                project: project,
                                onEdit: () => _editProject(project),
                                onDelete: () => _deleteProject(project),
                                onDuplicate: () => _duplicateProject(project),
                                formatDate: _formatDate,
                                formatCurrency: _formatCurrency,
                                stageLabel:
                                    projectStageLabels[project.status] ?? project.status,
                              ),
                            ),
                          )
                          .toList(),
            ),
            const SizedBox(height: 20),
          ],
          _InfoCard(
            title: 'Upcoming payments',
            children: isLoading
                ? _buildLoadingPayments()
                : upcomingPayments.isEmpty
                    ? [const Text('No upcoming payments.')]
                    : upcomingPayments
                        .map(
                          (payment) => _PaymentRow(
                            payment: payment,
                            formatDate: _formatDate,
                            formatCurrency: _formatCurrency,
                            onEdit: payment.sourcePayment == null
                                ? null
                                : () => _editPayment(payment.sourcePayment!),
                            onDelete: payment.sourcePayment == null
                                ? null
                                : () => _deletePayment(payment.sourcePayment!),
                            onMarkPaid:
                                payment.sourcePayment?.status == 'planned'
                                    ? () => _markPaymentAsPaid(payment.sourcePayment!)
                                    : null,
                          ),
                        )
                        .toList(),
          ),
          const SizedBox(height: 20),
          _InfoCard(
            title: 'Payment history',
            children: isLoading
                ? _buildLoadingPayments()
                : pastPayments.isEmpty
                    ? [const Text('No payment history yet.')]
                    : pastPayments
                        .map(
                          (payment) => _PaymentRow(
                            payment: payment,
                            formatDate: _formatDate,
                            formatCurrency: _formatCurrency,
                            onEdit: payment.sourcePayment == null
                                ? null
                                : () => _editPayment(payment.sourcePayment!),
                            onDelete: payment.sourcePayment == null
                                ? null
                                : () => _deletePayment(payment.sourcePayment!),
                          ),
                        )
                        .toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLoadingDetails() {
    return const [
      SkeletonBox(height: 14, width: 120, margin: EdgeInsets.only(bottom: 12)),
      SkeletonBox(height: 14, width: 180, margin: EdgeInsets.only(bottom: 12)),
      SkeletonBox(height: 14, width: 140, margin: EdgeInsets.only(bottom: 12)),
      SkeletonBox(height: 14, width: 200),
    ];
  }

  List<Widget> _buildLoadingProjects() {
    return List.generate(
      3,
      (_) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 14, width: 160),
                  SizedBox(height: 6),
                  SkeletonBox(height: 12, width: 120),
                ],
              ),
            ),
            SizedBox(width: 12),
            SkeletonBox(height: 14, width: 60),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLoadingPayments() {
    return List.generate(
      3,
      (_) => const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 14, width: 160),
                  SizedBox(height: 6),
                  SkeletonBox(height: 12, width: 120),
                ],
              ),
            ),
            SizedBox(width: 12),
            SkeletonBox(height: 14, width: 70),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteClient() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete client'),
        content: const Text('This will delete the client and its projects and payments.'),
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

  Future<void> _editClient() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _client.name);
    final contactController =
        TextEditingController(text: _client.contactPerson ?? '');
    final phoneController = TextEditingController(text: _client.phone ?? '');
    final emailController = TextEditingController(text: _client.email ?? '');
    final telegramController = TextEditingController(text: _client.telegram ?? '');
    final amountController = TextEditingController(
      text: _isRetainerClient(_client)
          ? (_client.retainerSettings?.amount ?? 0).toStringAsFixed(0)
          : (_client.plannedBudget?.toStringAsFixed(0) ?? ''),
    );
    var selectedFrequency = _client.retainerSettings?.frequency;
    DateTime? selectedDate = _client.retainerSettings?.nextPaymentDate;

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit client'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Client name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a client name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: _isRetainerClient(_client)
                              ? 'Retainer amount (\\$)'
                              : 'Planned budget (\\$) (optional)',
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (_isRetainerClient(_client)) {
                            if (trimmed.isEmpty) {
                              return 'Enter a retainer amount';
                            }
                            final parsed =
                                double.tryParse(trimmed.replaceAll(',', '.'));
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid amount';
                            }
                          } else if (trimmed.isNotEmpty) {
                            final parsed =
                                double.tryParse(trimmed.replaceAll(',', '.'));
                            if (parsed == null || parsed < 0) {
                              return 'Enter a valid budget';
                            }
                          }
                          return null;
                        },
                      ),
                      if (_isRetainerClient(_client)) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedFrequency,
                          decoration:
                              const InputDecoration(labelText: 'Payment frequency'),
                          items: const [
                            DropdownMenuItem(
                              value: 'once_month',
                              child: Text('Once a month'),
                            ),
                            DropdownMenuItem(
                              value: 'twice_month',
                              child: Text('Twice a month'),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedFrequency = value;
                            });
                          },
                          validator: (value) {
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
                            selectedDate == null
                                ? 'Select a date'
                                : _formatDate(selectedDate!),
                          ),
                          trailing: const Icon(Icons.calendar_today_outlined),
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedDate ?? now,
                              firstDate: now,
                              lastDate: DateTime(now.year + 5),
                            );
                            if (picked == null) {
                              return;
                            }
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          },
                        ),
                        if (selectedDate == null)
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
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: contactController,
                        decoration:
                            const InputDecoration(labelText: 'Contact person'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: telegramController,
                        decoration: const InputDecoration(labelText: 'Telegram'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final isValid = formKey.currentState?.validate() ?? false;
                    if (_isRetainerClient(_client) && selectedDate == null) {
                      setDialogState(() {});
                      return;
                    }
                    if (!isValid) {
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Save'),
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

    final amountValue = amountController.text.trim();
    final parsedAmount = amountValue.isEmpty
        ? null
        : double.tryParse(amountValue.replaceAll(',', '.'));
    final now = DateTime.now();
    final updatedSettings = _isRetainerClient(_client)
        ? RetainerSettings(
            amount: parsedAmount ?? 0,
            frequency: selectedFrequency ?? 'once_month',
            nextPaymentDate: selectedDate ?? now,
            isEnabled: _client.retainerSettings?.isEnabled ?? true,
            updatedAt: now,
          )
        : null;
    final updatedClient = Client(
      id: _client.id,
      name: nameController.text.trim(),
      type: _client.type,
      contactPerson: contactController.text.trim().isEmpty
          ? null
          : contactController.text.trim(),
      phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
      email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
      telegram:
          telegramController.text.trim().isEmpty ? null : telegramController.text.trim(),
      plannedBudget: _isRetainerClient(_client) ? null : parsedAmount,
      createdAt: _client.createdAt,
      updatedAt: now,
      avatarColorHex: _client.avatarColorHex,
      retainerSettings: updatedSettings,
    );
    await widget.onUpdateClient(updatedClient);
    if (!mounted) {
      return;
    }
    setState(() {
      _client = updatedClient;
    });
  }

  Future<void> _duplicateClient() async {
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
                    decoration: const InputDecoration(labelText: 'New name'),
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
    await widget.onDuplicateClient(_client, newName, copyWithAllSettings);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Client duplicated')),
    );
  }

  Future<void> _duplicateProject(Project project) async {
    final nameController = TextEditingController();
    var copyWithAllSettings = true;
    var isValid = false;

    final shouldDuplicate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Duplicate project'),
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
    final newTitle = nameController.text.trim();
    if (newTitle.isEmpty) {
      return;
    }
    final duplicated =
        await widget.onDuplicateProject(project, newTitle, copyWithAllSettings);
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
      _payments.removeWhere((payment) => payment.projectId == project.id);
    });
  }

  Future<void> _editProject(Project project) async {
    final titleController = TextEditingController(text: project.title);
    final amountController =
        TextEditingController(text: project.amount.toStringAsFixed(0));
    var selectedStage = project.status;
    DateTime? selectedDeadline = project.deadlineDate;
    var showErrors = false;

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit project'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Project name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Project amount (\\$)',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStage.isEmpty ? null : selectedStage,
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
                        setDialogState(() {
                          selectedStage = value ?? selectedStage;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Deadline (optional)'),
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
                    if (showErrors)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter a name and amount',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
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
                    final title = titleController.text.trim();
                    final amount = double.tryParse(
                      amountController.text.trim().replaceAll(',', '.'),
                    );
                    if (title.isEmpty || amount == null || amount <= 0) {
                      setDialogState(() {
                        showErrors = true;
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Save'),
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

    final updatedAmount =
        double.tryParse(amountController.text.trim().replaceAll(',', '.')) ??
            project.amount;
    final updatedTitle = titleController.text.trim();
    final updatedProject = Project(
      id: project.id,
      clientId: project.clientId,
      title: updatedTitle,
      amount: updatedAmount,
      status: selectedStage,
      deadlineDate: selectedDeadline,
      createdAt: project.createdAt,
      updatedAt: DateTime.now(),
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

  Future<void> _markPaymentAsPaid(ProjectPayment payment) async {
    final now = DateTime.now();
    final updated = ProjectPayment(
      id: payment.id,
      projectId: payment.projectId,
      amount: payment.amount,
      kind: payment.kind,
      status: 'paid',
      dueDate: payment.dueDate,
      paidDate: payment.paidDate ?? now,
      createdAt: payment.createdAt,
      updatedAt: now,
    );
    await widget.onUpdatePayment(payment, updated);
    if (!mounted) {
      return;
    }
    setState(() {
      final index = _payments.indexOf(payment);
      if (index != -1) {
        _payments[index] = updated;
      }
    });
  }

  Future<void> _editPayment(ProjectPayment payment) async {
    final amountController =
        TextEditingController(text: payment.amount.toStringAsFixed(0));
    var selectedKind = payment.kind;
    var selectedStatus = payment.status;
    DateTime? selectedDueDate = payment.dueDate;
    DateTime? selectedPaidDate = payment.paidDate;
    var showErrors = false;

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit payment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (\\$)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    if (showErrors &&
                        (double.tryParse(amountController.text.trim().replaceAll(',', '.')) ==
                            null)) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter a valid amount',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedKind,
                      decoration: const InputDecoration(
                        labelText: 'Kind',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'deposit', child: Text('Deposit')),
                        DropdownMenuItem(value: 'milestone', child: Text('Milestone')),
                        DropdownMenuItem(value: 'final', child: Text('Final payment')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedKind = value ?? selectedKind;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'planned', child: Text('Planned')),
                        DropdownMenuItem(value: 'paid', child: Text('Paid')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedStatus = value ?? selectedStatus;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Due date (optional)'),
                      subtitle: Text(
                        selectedDueDate == null
                            ? 'Select a date'
                            : _formatDate(selectedDueDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today_outlined),
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDueDate ?? now,
                          firstDate: DateTime(now.year - 5),
                          lastDate: DateTime(now.year + 5),
                        );
                        if (picked == null) {
                          return;
                        }
                        setDialogState(() {
                          selectedDueDate = picked;
                        });
                      },
                    ),
                    if (selectedStatus == 'paid') ...[
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Paid date'),
                        subtitle: Text(
                          selectedPaidDate == null
                              ? 'Select a date'
                              : _formatDate(selectedPaidDate!),
                        ),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedPaidDate ?? now,
                            firstDate: DateTime(now.year - 5),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked == null) {
                            return;
                          }
                          setDialogState(() {
                            selectedPaidDate = picked;
                          });
                        },
                      ),
                      if (showErrors && selectedPaidDate == null) ...[
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(
                      amountController.text.trim().replaceAll(',', '.'),
                    );
                    if (amount == null || amount <= 0) {
                      setDialogState(() {
                        showErrors = true;
                      });
                      return;
                    }
                    if (selectedStatus == 'paid' && selectedPaidDate == null) {
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
    final updatedAmount =
        double.tryParse(amountController.text.trim().replaceAll(',', '.')) ??
            payment.amount;
    final now = DateTime.now();
    final updated = ProjectPayment(
      id: payment.id,
      projectId: payment.projectId,
      amount: updatedAmount,
      kind: selectedKind,
      status: selectedStatus,
      dueDate: selectedDueDate,
      paidDate: selectedStatus == 'paid' ? (selectedPaidDate ?? now) : null,
      createdAt: payment.createdAt,
      updatedAt: now,
    );
    await widget.onUpdatePayment(payment, updated);
    if (!mounted) {
      return;
    }
    setState(() {
      final index = _payments.indexOf(payment);
      if (index != -1) {
        _payments[index] = updated;
      }
    });
  }

  Future<void> _deletePayment(ProjectPayment payment) async {
    await widget.onDeletePayment(payment);
    if (!mounted) {
      return;
    }
    setState(() {
      _payments.remove(payment);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
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

  bool _isRetainerClient(Client client) {
    return client.type == 'retainer';
  }

  List<_ClientPaymentDisplay> _buildClientPayments(DateTime now) {
    final combined = <_ClientPaymentDisplay>[];
    if (_isRetainerClient(_client)) {
      final settings = _client.retainerSettings;
      if (settings != null && settings.isEnabled) {
        final start = now.subtract(const Duration(days: 30));
        final end = now.add(const Duration(days: 60));
        final dates = _scheduledRetainerDates(settings, start, end);
        for (final date in dates) {
          combined.add(
            _ClientPaymentDisplay(
              amount: settings.amount,
              date: date,
              title: 'Retainer',
              subtitle:
                  '${settings.frequency == 'twice_month' ? 'Twice a month' : 'Once a month'} • Planned • ${_formatDate(date)}',
              status: 'planned',
            ),
          );
        }
      }
    } else {
      for (final payment in _payments) {
        final project = _projectForPayment(payment);
        if (project == null) {
          continue;
        }
        if (payment.status == 'planned') {
          final dueDate = payment.dueDate ?? payment.createdAt;
          combined.add(
            _ClientPaymentDisplay(
              amount: payment.amount,
              date: dueDate,
              title: _projectTitleForPayment(payment),
              subtitle: payment.dueDate == null
                  ? '${_paymentKindLabel(payment.kind)} • Planned • No due date'
                  : '${_paymentKindLabel(payment.kind)} • Planned • ${_formatDate(payment.dueDate!)}',
              status: 'planned',
              sourcePayment: payment,
            ),
          );
        }
        if (payment.status == 'paid' && payment.paidDate != null) {
          combined.add(
            _ClientPaymentDisplay(
              amount: payment.amount,
              date: payment.paidDate!,
              title: _projectTitleForPayment(payment),
              subtitle:
                  '${_paymentKindLabel(payment.kind)} • Paid • ${_formatDate(payment.paidDate!)}',
              status: 'paid',
              sourcePayment: payment,
            ),
          );
        }
      }
    }
    combined.sort((a, b) => a.date.compareTo(b.date));
    return combined;
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

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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

  String _paymentKindLabel(String kind) {
    return switch (kind) {
      'deposit' => 'Deposit',
      'milestone' => 'Milestone',
      'final' => 'Final payment',
      _ => 'Other',
    };
  }

  String _projectTitleForPayment(ProjectPayment payment) {
    final project = _projects.cast<Project?>().firstWhere(
          (project) => project?.id == payment.projectId,
          orElse: () => null,
        );
    return project?.title ?? 'Unknown project';
  }

  Project? _projectForPayment(ProjectPayment payment) {
    return _projects.cast<Project?>().firstWhere(
          (project) => project?.id == payment.projectId,
          orElse: () => null,
        );
  }

  List<String> _buildSummaryChips() {
    final chips = <String>[];
    chips.add(_isRetainerClient(_client) ? 'Retainer' : 'Project');
    if (_isRetainerClient(_client)) {
      final settings = _client.retainerSettings;
      if (settings != null) {
        chips.add(
          settings.frequency == 'twice_month' ? 'Twice a month' : 'Once a month',
        );
        chips.add('Next: ${_formatDate(settings.nextPaymentDate)}');
      }
    }
    return chips;
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

class _ClientPaymentDisplay {
  const _ClientPaymentDisplay({
    required this.amount,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.status,
    this.sourcePayment,
  });

  final double amount;
  final DateTime date;
  final String title;
  final String subtitle;
  final String status;
  final ProjectPayment? sourcePayment;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    required this.onEdit,
    required this.onDelete,
    required this.formatDate,
    required this.formatCurrency,
    required this.stageLabel,
  });

  final Project project;
  final VoidCallback onDuplicate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(DateTime) formatDate;
  final String Function(double) formatCurrency;
  final String stageLabel;

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
                project.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                stageLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (project.deadlineDate != null) ...[
                const SizedBox(height: 2),
                Text(
                  formatDate(project.deadlineDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatCurrency(project.amount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz),
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            } else if (value == 'duplicate') {
              onDuplicate();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
            PopupMenuItem(
              value: 'duplicate',
              child: Text('Duplicate'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.payment,
    required this.formatDate,
    required this.formatCurrency,
    this.onEdit,
    this.onDelete,
    this.onMarkPaid,
  });

  final _ClientPaymentDisplay payment;
  final String Function(DateTime) formatDate;
  final String Function(double) formatCurrency;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkPaid;

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
                  payment.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(payment.amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (onEdit != null || onDelete != null || onMarkPaid != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit?.call();
            } else if (value == 'paid') {
              onMarkPaid?.call();
                } else if (value == 'delete') {
                  onDelete?.call();
                }
              },
              itemBuilder: (context) => [
                if (onMarkPaid != null)
                  const PopupMenuItem(
                    value: 'paid',
                    child: Text('Mark as paid'),
                  ),
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
