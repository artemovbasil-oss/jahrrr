import 'package:flutter/foundation.dart';

enum SyncStatus { syncing, synced, failed }

class SyncStatusController extends ChangeNotifier {
  SyncStatusController({SyncStatus initialStatus = SyncStatus.syncing})
      : _status = initialStatus;

  SyncStatus _status;

  SyncStatus get status => _status;

  bool get isLoading => _status == SyncStatus.syncing;
  bool get isFailed => _status == SyncStatus.failed;

  void setLoading() {
    if (_status == SyncStatus.syncing) {
      return;
    }
    _status = SyncStatus.syncing;
    notifyListeners();
  }

  void setSynced() {
    if (_status == SyncStatus.synced) {
      return;
    }
    _status = SyncStatus.synced;
    notifyListeners();
  }

  void setFailed() {
    if (_status == SyncStatus.failed) {
      return;
    }
    _status = SyncStatus.failed;
    notifyListeners();
  }
}
