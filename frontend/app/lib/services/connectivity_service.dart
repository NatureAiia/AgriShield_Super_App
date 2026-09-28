import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper so the rest of the app depends on one small interface
/// instead of the connectivity_plus API directly.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Stream<bool> onChange() {
    return _connectivity.onConnectivityChanged.map(
      (results) => !results.contains(ConnectivityResult.none),
    );
  }
}
