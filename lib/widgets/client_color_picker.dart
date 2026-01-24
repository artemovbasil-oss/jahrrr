import 'package:flutter/material.dart';

import '../utils/client_color.dart';

class ClientColorPicker extends StatelessWidget {
  const ClientColorPicker({
    super.key,
    required this.selectedColorHex,
    required this.onColorSelected,
    this.showError = false,
  });

  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = normalizeClientColorHex(selectedColorHex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avatar color',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kClientColorPalette.map((color) {
            final hex = colorToHex(color);
            final isSelected = hex == selected;
            return _ColorChip(
              color: color,
              isSelected: isSelected,
              onTap: () => onColorSelected(hex),
            );
          }).toList(),
        ),
        if (showError) ...[
          const SizedBox(height: 6),
          Text(
            'Select a color',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.outline.withOpacity(0.4),
              width: isSelected ? 2.2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  size: 18,
                  color: theme.colorScheme.onPrimary,
                )
              : null,
        ),
      ),
    );
  }
}
