import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../data/repositories/product_repository.dart';
import '../data/services/connectivity_service.dart';
import '../data/services/firebase_service.dart';

enum ShopState { initial, loading, loaded, error, empty }

enum ProductDetailsState { initial, loading, loaded, error }

/// Connectivity status used by the UI layer
enum ConnectivityStatus {
  /// Normal — user is online (or we haven't determined yet)
  online,

  /// User just went offline
  offline,

  /// User just came back online (auto-dismissed after a few seconds)
  restored,
}

class ShopProvider with ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  final ConnectivityService _connectivityService = ConnectivityService();

  // Connectivity subscription
  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<List<Product>>? _productsStreamSubscription;

  // ── Initialization ────────────────────────────────────────────
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ── Shop state ────────────────────────────────────────────────
  ShopState _state = ShopState.initial;
  ShopState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _dataSourceDescription;
  String? get dataSourceDescription => _dataSourceDescription;

  // ── Connectivity ──────────────────────────────────────────────
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  bool _fromCache = false;
  bool get fromCache => _fromCache;

  ConnectivityStatus _connectivityStatus = ConnectivityStatus.online;
  ConnectivityStatus get connectivityStatus => _connectivityStatus;

  Timer? _restoredTimer;

  // ── Products ──────────────────────────────────────────────────
  List<Product> _products = [];
  List<Product> get products => List.unmodifiable(_products);

  // ── Product Details ───────────────────────────────────────────
  ProductDetailsState _productDetailsState = ProductDetailsState.initial;
  ProductDetailsState get productDetailsState => _productDetailsState;

  String? _productDetailsError;
  String? get productDetailsError => _productDetailsError;

  bool _productDetailsFromCache = false;
  bool get productDetailsFromCache => _productDetailsFromCache;

  // ── Category Filter ───────────────────────────────────────────
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    if (_selectedCategory == null) {
      return List.unmodifiable(_products);
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  // ── Constructor ───────────────────────────────────────────────
  ShopProvider() {
    _bootstrap();
  }

  /// Bootstrap the provider:
  /// 1. Initialize connectivity service (waits for first real check).
  /// 2. Start listening for changes.
  /// 3. Fetch products.
  Future<void> _bootstrap() async {
    try {
      // Initialize the singleton connectivity service
      await _connectivityService.initialize();

      // Read the result of the first check
      _isOnline = _connectivityService.lastKnownState;

      // Start listening for real-time changes
      _initConnectivityListener();

      // Start listening for real-time product updates
      _initProductsStream();

      // Fetch products (online or from cache/assets)
      await fetchProducts();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // If bootstrap fails, still try to load from local data
      debugPrint('ShopProvider bootstrap error: $e');

      // Set to offline mode and try to load from cache/assets
      _isOnline = false;
      _connectivityStatus = ConnectivityStatus.offline;

      // Try to fetch products anyway (will fallback to local data)
      await fetchProducts();

      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Real-time connectivity listener.
  /// Reacts only to *actual* state transitions.
  void _initConnectivityListener() {
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (hasInternet) {
        if (_isOnline == hasInternet) return;

        final wasOnline = _isOnline;
        _isOnline = hasInternet;

        // ── Went offline ──
        if (wasOnline && !hasInternet) {
          _connectivityStatus = ConnectivityStatus.offline;
          _restoredTimer?.cancel();
          notifyListeners();
          return;
        }

        // ── Came back online ──
        if (!wasOnline && hasInternet) {
          _connectivityStatus = ConnectivityStatus.restored;
          notifyListeners();

          // Auto-refresh products from network
          fetchProducts();

          // Auto-dismiss "Connection Restored" after 3 seconds
          _restoredTimer?.cancel();
          _restoredTimer = Timer(const Duration(seconds: 3), () {
            _connectivityStatus = ConnectivityStatus.online;
            notifyListeners();
          });
          return;
        }
      },
      onError: (error) {
        debugPrint('Connectivity listener error: $error');
      },
    );
  }

  /// Real-time products stream listener
  void _initProductsStream() {
    try {
      if (!FirebaseService.isAvailable) {
        debugPrint('Skipping products stream: Firebase not available');
        return;
      }
      
      _productsStreamSubscription = _repository.productsStream.listen(
        (newProducts) {
          if (newProducts.isNotEmpty && _isOnline) {
            _products = newProducts;
            _state = ShopState.loaded;
            _errorMessage = null;
            _fromCache = false;
            _dataSourceDescription = 'Live data';
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('Products stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Error setting up products stream: $e');
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _productsStreamSubscription?.cancel();
    _restoredTimer?.cancel();
    super.dispose();
  }

  // ─── Fetch Products ─────────────────────────────────────────
  Future<void> fetchProducts() async {
    // Don't show loading spinner if products are already displayed (refresh)
    if (_products.isEmpty) {
      _state = ShopState.loading;
      notifyListeners();
    }

    try {
      final result = await _repository.getProducts();

      if (result.isSuccess) {
        _products = result.products!;
        _isOnline = result.isOnline;
        _fromCache = result.fromCache;
        _dataSourceDescription = result.sourceDescription;

        if (_products.isEmpty) {
          _state = ShopState.empty;
        } else {
          _state = ShopState.loaded;
        }

        _errorMessage = null;

        // Don't change connectivity status on initial fetch
        // The connectivity listener handles real-time changes
        // Only update status if we have an explicit online result and were offline
        if (result.isOnline &&
            _connectivityStatus == ConnectivityStatus.offline) {
          _connectivityStatus = ConnectivityStatus.restored;
          _restoredTimer?.cancel();
          _restoredTimer = Timer(const Duration(seconds: 3), () {
            _connectivityStatus = ConnectivityStatus.online;
            notifyListeners();
          });
        }
      } else {
        // Only show error state if we have no products at all
        if (_products.isEmpty) {
          _state = ShopState.error;
          _errorMessage = result.error ?? 'Unknown error occurred';
        }
        // Don't change connectivity status here - let the connectivity listener handle it
      }
    } catch (e) {
      if (_products.isEmpty) {
        _state = ShopState.error;
        _errorMessage = e.toString();
      }
      // Don't change connectivity status here - let the connectivity listener handle it
    }

    if (!_isInitialized) {
      _isInitialized = true;
    }
    notifyListeners();
  }

  /// Retry fetching products
  Future<void> retry() async {
    await fetchProducts();
  }

  // ─── Product Details ────────────────────────────────────────

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchProductDetails(String productId) async {
    _productDetailsState = ProductDetailsState.loading;
    _productDetailsError = null;
    _productDetailsFromCache = false;
    notifyListeners();

    try {
      final existingProduct = getProductById(productId);
      if (existingProduct != null) {
        _productDetailsState = ProductDetailsState.loaded;
        _productDetailsFromCache = false;
        notifyListeners();
        return;
      }

      // Fetch from repository
      final result = await _repository.getProductById(productId);

      if (result.isSuccess && result.products!.isNotEmpty) {
        _productDetailsState = ProductDetailsState.loaded;
        _productDetailsFromCache = result.fromCache;
        notifyListeners();
      } else {
        _productDetailsState = ProductDetailsState.error;
        _productDetailsError = result.error ?? 'Product not found';
        _productDetailsFromCache = result.fromCache;
        notifyListeners();
      }
    } catch (e) {
      _productDetailsState = ProductDetailsState.error;
      _productDetailsError = 'Failed to load product details: $e';
      _productDetailsFromCache = false;
      notifyListeners();
    }
  }

  void resetProductDetailsState() {
    _productDetailsState = ProductDetailsState.initial;
    _productDetailsError = null;
    _productDetailsFromCache = false;
    notifyListeners();
  }

  // ─── Products ───────────────────────────────────────────────

  List<Product> get favorites => _products.where((p) => p.isFavorite).toList();

  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<String> get categories {
    return _products.map((p) => p.category).toSet().toList();
  }

  // ─── Cart ───────────────────────────────────────────────────
  final Map<String, CartItem> _cartItems = {};

  List<CartItem> get cartItems => _cartItems.values.toList();
  int get cartCount => _cartItems.length;

  int get cartTotalItems {
    int total = 0;
    for (final item in _cartItems.values) {
      total += item.quantity;
    }
    return total;
  }

  // ─── Favorite Logic ─────────────────────────────────────────
  void toggleFavorite(String productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index].isFavorite = !_products[index].isFavorite;
      notifyListeners();
    }
  }

  // ─── Cart Logic ─────────────────────────────────────────────
  void addToCart(String productId) {
    if (_cartItems.containsKey(productId)) {
      _cartItems[productId]!.quantity += 1;
    } else {
      final product = _products.firstWhere((p) => p.id == productId);
      _cartItems[productId] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    if (_cartItems.containsKey(productId)) {
      _cartItems[productId]!.quantity += 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (_cartItems.containsKey(productId)) {
      if (_cartItems[productId]!.quantity > 1) {
        _cartItems[productId]!.quantity -= 1;
      } else {
        _cartItems.remove(productId);
      }
      notifyListeners();
    }
  }

  double calculateTotal() {
    double total = 0.0;
    _cartItems.forEach((_, item) {
      total += item.subtotal;
    });
    return total;
  }

  bool isInCart(String productId) {
    return _cartItems.containsKey(productId);
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
