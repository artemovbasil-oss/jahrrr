import 'package:flutter/material.dart';

import '../models/project.dart';
import '../widgets/milestone_project_card.dart';

enum MilestoneFilter { all, milestones, deadlines }

class MilestonesDeadlinesScreen extends StatefulWidget {
  const MilestonesDeadlinesScreen({
    super.key,
    required this.projects,
    required this.clientNameForId,
    required this.clientColorForId,
    required this.formatCurrency,
    required this.stageProgress,
    required this.stageColor,
    required this.onProjectTap,
  });

  final List<Project> projects;
  final String Function(String clientId) clientNameForId;
  final Color Function(String clientId) clientColorForId;
  final String Function(double amount) formatCurrency;
  final double Function(String stage) stageProgress;
  final Color Function(String stage) stageColor;
  final ValueChanged<Project> onProjectTap;

  @override
  State<MilestonesDeadlinesScreen> createState() => _MilestonesDeadlinesScreenState();
}

class _MilestonesDeadlinesScreenState extends State<MilestonesDeadlinesScreen> {
  MilestoneFilter _filter = MilestoneFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredProjects = _applyFilter(widget.projects);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestones & Deadlines'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            _MilestoneFilterBar(
              filter: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: 16),
            if (filteredProjects.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _emptyLabelForFilter(_filter),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...filteredProjects.map(
                (project) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MilestoneProjectCard(
                    project: project,
                    clientName: widget.clientNameForId(project.clientId),
                    amountLabel: widget.formatCurrency(project.amount),
                    clientTagColor:
                        theme.colorScheme.surfaceVariant.withOpacity(0.6),
                    stageTagColor: widget.clientColorForId(project.clientId)
                        .withOpacity(theme.brightness == Brightness.dark ? 0.28 : 0.18),
                    stageTextColor: theme.brightness == Brightness.dark
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    progressValue: widget.stageProgress(project.status),
                    progressColor: widget.stageColor(project.status),
                    onTap: () => widget.onProjectTap(project),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Project> _applyFilter(List<Project> projects) {
    switch (_filter) {
      case MilestoneFilter.milestones:
        return projects.where((project) => project.deadlineDate == null).toList();
      case MilestoneFilter.deadlines:
        return projects.where((project) => project.deadlineDate != null).toList();
      case MilestoneFilter.all:
        return projects;
    }
  }

  String _emptyLabelForFilter(MilestoneFilter filter) {
    switch (filter) {
      case MilestoneFilter.milestones:
        return 'No milestones yet.';
      case MilestoneFilter.deadlines:
        return 'No deadlines yet.';
      case MilestoneFilter.all:
        return 'Add a project to track milestones.';
    }
  }
}

class _MilestoneFilterBar extends StatelessWidget {
  const _MilestoneFilterBar({
    required this.filter,
    required this.onChanged,
  });

  final MilestoneFilter filter;
  final ValueChanged<MilestoneFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MilestoneFilter>(
      segments: const [
        ButtonSegment(value: MilestoneFilter.all, label: Text('All')),
        ButtonSegment(value: MilestoneFilter.milestones, label: Text('Milestones')),
        ButtonSegment(value: MilestoneFilter.deadlines, label: Text('Deadlines')),
      ],
      selected: {filter},
      onSelectionChanged: (value) => onChanged(value.first),
      showSelectedIcon: false,
    );
  }
}
