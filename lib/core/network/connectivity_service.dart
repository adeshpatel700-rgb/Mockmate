/// Connectivity Service — monitors network status for offline support.
///
/// WHY CONNECTIVITY CHECKING?
/// Users may lose internet during an interview. We need to:
/// 1. Detect when offline and show friendly UI
/// 2. Cache data so the app still works
/// 3. Queue failed requests to retry when back online
library;

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  StreamController<bool>? _connectionStatusController;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Stream that emits true when online, false when offline.
  Stream<bool> get connectionStatus {
    _connectionStatusController ??= StreamController<bool>.broadcast();

    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final isConnected = results.any((result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet);

      _connectionStatusController?.add(isConnected);
    });

    return _connectionStatusController!.stream;
  }

  /// Check current connection status (one-time check).
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  void dispose() {
    _connectionStatusController?.close();
  }
}
