import 'package:flutter/material.dart';

enum OperationKind { create, update, delete }

class OperationFeedback {
  OperationFeedback(this.context);

  final BuildContext context;

  void showProgress(OperationKind kind) {
    _showSnackBar(
      _progressLabel(kind),
      duration: const Duration(minutes: 5),
    );
  }

  void showSuccess(OperationKind kind) {
    _showSnackBar(
      _successLabel(kind),
      duration: const Duration(seconds: 2),
    );
  }

  void showFailure(OperationKind kind, {VoidCallback? onRetry}) {
    _showSnackBar(
      _failureLabel(kind),
      duration: const Duration(seconds: 4),
      action: onRetry == null
          ? null
          : SnackBarAction(
              label: 'Retry',
              onPressed: onRetry,
            ),
    );
  }

  void _showSnackBar(
    String message, {
    required Duration duration,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  String _progressLabel(OperationKind kind) {
    switch (kind) {
      case OperationKind.create:
        return 'Creating…';
      case OperationKind.update:
        return 'Updating…';
      case OperationKind.delete:
        return 'Deleting…';
    }
  }

  String _successLabel(OperationKind kind) {
    switch (kind) {
      case OperationKind.create:
        return 'Created';
      case OperationKind.update:
        return 'Updated';
      case OperationKind.delete:
        return 'Deleted';
    }
  }

  String _failureLabel(OperationKind kind) {
    switch (kind) {
      case OperationKind.create:
        return 'Create failed';
      case OperationKind.update:
        return 'Update failed';
      case OperationKind.delete:
        return 'Delete failed';
    }
  }
}
