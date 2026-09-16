import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Manages real-time network connectivity status across the application.
class NetworkProvider extends ChangeNotifier {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  List<ConnectivityResult> _connectivityResults = [ConnectivityResult.wifi];
  bool _wasOffline = false;
  bool _showBackOnlineBanner = false;
  Timer? _backOnlineTimer;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get showBackOnlineBanner => _showBackOnlineBanner;
  List<ConnectivityResult> get connectivityResults => _connectivityResults;

  String get connectionType {
    if (!_isOnline || _connectivityResults.contains(ConnectivityResult.none)) {
      return 'Offline';
    }
    if (_connectivityResults.contains(ConnectivityResult.wifi)) {
      return 'Wi-Fi';
    }
    if (_connectivityResults.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    }
    if (_connectivityResults.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    }
    if (_connectivityResults.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    }
    return 'Connected';
  }

  NetworkProvider({
    Connectivity? connectivity,
    bool? initialIsOnline,
    bool enableListener = true,
  }) : _connectivity = connectivity ?? Connectivity() {
    if (initialIsOnline != null) {
      _isOnline = initialIsOnline;
      _connectivityResults = initialIsOnline
          ? [ConnectivityResult.wifi]
          : [ConnectivityResult.none];
    }
    if (enableListener) {
      _initConnectivity();
    }
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateResults(results, isInitial: true);
    } catch (e) {
      debugPrint('Notice: Initial connectivity check fallback: $e');
    }

    try {
      _subscription = _connectivity.onConnectivityChanged.listen(
        (results) => _updateResults(results),
        onError: (e) {
          debugPrint('Connectivity stream notice: $e');
        },
      );
    } catch (e) {
      debugPrint('Connectivity listener registration notice: $e');
    }
  }

  void _updateResults(List<ConnectivityResult> results, {bool isInitial = false}) {
    _connectivityResults = results;
    final bool newIsOnline = results.any((r) => r != ConnectivityResult.none);

    if (newIsOnline != _isOnline) {
      if (!isInitial) {
        if (!newIsOnline) {
          _wasOffline = true;
          _showBackOnlineBanner = false;
          _backOnlineTimer?.cancel();
        } else if (_wasOffline) {
          // Device just transitioned from offline -> online
          _showBackOnlineBanner = true;
          _wasOffline = false;
          _backOnlineTimer?.cancel();
          _backOnlineTimer = Timer(const Duration(seconds: 3), () {
            _showBackOnlineBanner = false;
            notifyListeners();
          });
        }
      }
      _isOnline = newIsOnline;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  /// Manually check connection status (e.g. user tapped "Retry")
  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateResults(results);
    } catch (e) {
      debugPrint('Error refreshing connectivity: $e');
    }
  }

  /// Override state for automated widget and integration tests
  @visibleForTesting
  void setOnlineStatusForTesting(bool isOnline, {List<ConnectivityResult>? results}) {
    _isOnline = isOnline;
    _connectivityResults = results ??
        (isOnline ? [ConnectivityResult.wifi] : [ConnectivityResult.none]);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _backOnlineTimer?.cancel();
    super.dispose();
  }
}
