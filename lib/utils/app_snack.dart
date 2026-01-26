import 'package:flutter/material.dart';

enum AppSnackType { info, success, error, loading }

class AppSnack {
  static const Duration _defaultLoadingDuration = Duration(minutes: 5);
  static const Duration _defaultSuccessDuration = Duration(seconds: 2);
  static const Duration _defaultErrorDuration = Duration(seconds: 4);
  static const Duration _defaultInfoDuration = Duration(seconds: 3);

  static void showLoading(
    BuildContext context,
    String message, {
    Duration duration = _defaultLoadingDuration,
  }) {
    _show(
      context,
      message,
      type: AppSnackType.loading,
      duration: duration,
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = _defaultSuccessDuration,
  }) {
    _show(
      context,
      message,
      type: AppSnackType.success,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = _defaultInfoDuration,
  }) {
    _show(
      context,
      message,
      type: AppSnackType.info,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultErrorDuration,
  }) {
    _show(
      context,
      message,
      type: AppSnackType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required AppSnackType type,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final backgroundColor = scheme.surfaceContainerHigh;
    final textColor = scheme.onSurface;

    final action = (actionLabel != null && onAction != null)
        ? SnackBarAction(
            label: actionLabel,
            onPressed: onAction,
            textColor: scheme.primary,
          )
        : null;

    messenger.showSnackBar(
      SnackBar(
        content: _SnackContent(
          message: message,
          type: type,
          textColor: textColor,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        elevation: 6,
        duration: duration,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        action: action,
      ),
    );
  }
}

class _SnackContent extends StatelessWidget {
  const _SnackContent({
    required this.message,
    required this.type,
    required this.textColor,
  });

  final String message;
  final AppSnackType type;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _buildLeading(theme),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildLeading(ThemeData theme) {
    switch (type) {
      case AppSnackType.loading:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        );
      case AppSnackType.success:
        return Icon(
          Icons.check_circle_outline,
          color: theme.colorScheme.primary,
        );
      case AppSnackType.error:
        return Icon(
          Icons.error_outline,
          color: theme.colorScheme.error,
        );
      case AppSnackType.info:
        return Icon(
          Icons.info_outline,
          color: theme.colorScheme.primary,
        );
    }
  }
}
