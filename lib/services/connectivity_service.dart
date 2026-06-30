import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityService() {
    _init();
  }

  Future<void> _init() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);

    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final nowOnline = !results.contains(ConnectivityResult.none);
    if (_isOnline != nowOnline) {
      _isOnline = nowOnline;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

