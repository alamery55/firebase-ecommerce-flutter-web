import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;


/// Singleton service to monitor network connectivity and actual internet access.
/// Provides real-time connectivity status updates with proper internet verification.
/// Handles startup race conditions and false offline detection.
class ConnectivityService {
  // ── Singleton ────────────────────────────────────────────────
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  // Track initialization state
  bool _initialized = false;
  bool _lastKnownState = true;
  bool get lastKnownState => _lastKnownState;

  // Broadcast controller so multiple listeners can subscribe
  StreamController<bool>? _controller;
  StreamSubscription<List<ConnectivityResult>>? _rawSubscription;

  /// Initialize the service — call once at app startup.
  /// Safe to call multiple times; subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _controller = StreamController<bool>.broadcast();

    // Perform an instant check on the network adapter initially.
    // We do NOT do a full HTTP ping here to avoid showing false 
    // "No Internet" errors at startup. The real API calls will act as the true check.
    final result = await _connectivity.checkConnectivity();
    _lastKnownState = !result.contains(ConnectivityResult.none);
    _controller!.add(_lastKnownState);

    // Listen for subsequent changes
    _rawSubscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  /// Debounce timer to avoid rapid-fire events
  Timer? _debounce;

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      final hasNetwork = !results.contains(ConnectivityResult.none);

      if (!hasNetwork) {
        // Definitely offline — no adapter/connection at all
        if (_lastKnownState != false) {
          _lastKnownState = false;
          _controller?.add(false);
        }
        return;
      }

      // Has network adapter — verify real internet access
      final hasInternet = await _verifyInternetAccess();
      if (_lastKnownState != hasInternet) {
        _lastKnownState = hasInternet;
        _controller?.add(hasInternet);
      }
    });
  }

  /// The main stream to subscribe to.
  /// Emits `true` when online, `false` when offline.
  Stream<bool> get connectivityStream {
    if (_controller == null) {
      // Auto-initialize if someone subscribes before init()
      initialize();
    }
    return _controller!.stream;
  }

  /// One-shot check: do we have real internet right now?
  Future<bool> hasInternetConnection() async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      _lastKnownState = false;
      return false;
    }
    final ok = await _verifyInternetAccess();
    _lastKnownState = ok;
    return ok;
  }

  /// Quick adapter-level check (no HTTP).
  Future<bool> hasNetworkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Verify actual internet access by hitting lightweight endpoints.
  Future<bool> _verifyInternetAccess() async {
    // Primary fast check
    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode >= 200 && response.statusCode < 400) {
        return true;
      }
    } catch (_) {}

    // Fallback if google is blocked
    try {
      final response = await http
          .get(Uri.parse('https://fakestoreapi.com/products?limit=1'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {}

    return false;
  }

  /// Clean up resources.
  void dispose() {
    _debounce?.cancel();
    _rawSubscription?.cancel();
    _controller?.close();
    _initialized = false;
  }
}
