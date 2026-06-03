import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = false;

  // When offlineOnly is set, always report offline regardless of actual network.
  bool get isOnline => AppConstants.offlineOnly ? false : _isOnline;

  Stream<bool> get onlineStream => AppConstants.offlineOnly
      ? const Stream.empty()
      : _connectivity.onConnectivityChanged
          .map((results) => results.any((r) => r != ConnectivityResult.none));

  Future<void> init() async {
    if (AppConstants.offlineOnly) return;
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.any((r) => r != ConnectivityResult.none);
    onlineStream.listen((online) => _isOnline = online);
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.init();
  return service;
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onlineStream;
});
