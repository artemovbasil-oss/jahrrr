import 'package:flutter/material.dart';

import '../models/project.dart';

class MilestoneProjectCard extends StatelessWidget {
  const MilestoneProjectCard({
    super.key,
    required this.project,
    required this.clientName,
    required this.amountLabel,
    required this.clientTagColor,
    required this.stageTagColor,
    required this.stageTextColor,
    required this.progressValue,
    required this.progressColor,
    this.onTap,
  });

  final Project project;
  final String clientName;
  final String amountLabel;
  final Color clientTagColor;
  final Color stageTagColor;
  final Color stageTextColor;
  final double progressValue;
  final Color progressColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    amountLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxStageWidth = constraints.maxWidth * 0.6;
                  return Row(
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: _ProjectTag(
                          text: clientName,
                          backgroundColor: clientTagColor,
                          textColor: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 104,
                          maxWidth: maxStageWidth,
                        ),
                        child: _ProjectTag(
                          text: projectStageLabels[project.status] ?? project.status,
                          backgroundColor: stageTagColor,
                          textColor: stageTextColor,
                          textAlign: TextAlign.right,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectTag extends StatelessWidget {
  const _ProjectTag({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.textAlign = TextAlign.left,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;
  final TextAlign textAlign;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
      ),
    );
  }
}
