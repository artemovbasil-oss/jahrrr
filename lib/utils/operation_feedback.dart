import 'package:flutter/material.dart';

import 'app_snack.dart';

enum OperationKind { create, update, delete }

class OperationFeedback {
  OperationFeedback(this.context);

  final BuildContext context;

  void showProgress(OperationKind kind) {
    AppSnack.showLoading(context, _progressLabel(kind));
  }

  void showSuccess(OperationKind kind) {
    AppSnack.showSuccess(context, _successLabel(kind));
  }

  void showFailure(OperationKind kind, {VoidCallback? onRetry}) {
    AppSnack.showError(
      context,
      _failureLabel(kind),
      actionLabel: onRetry == null ? null : 'Retry',
      onAction: onRetry,
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
