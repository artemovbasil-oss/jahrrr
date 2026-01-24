import 'package:flutter/foundation.dart';

enum SyncStatus { loading, synced }

class SyncStatusController extends ChangeNotifier {
  SyncStatusController({SyncStatus initialStatus = SyncStatus.loading})
      : _status = initialStatus;

  SyncStatus _status;

  SyncStatus get status => _status;

  bool get isLoading => _status == SyncStatus.loading;

  void setLoading() {
    if (_status == SyncStatus.loading) {
      return;
    }
    _status = SyncStatus.loading;
    notifyListeners();
  }

  void setSynced() {
    if (_status == SyncStatus.synced) {
      return;
    }
    _status = SyncStatus.synced;
    notifyListeners();
  }
}
