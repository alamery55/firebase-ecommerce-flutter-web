import '../../models/product.dart';
import '../datasources/firebase_data_source.dart';
import '../datasources/local_data_source.dart';
import '../services/connectivity_service.dart';

class ProductResult {
  final List<Product>? products;
  final String? error;
  final bool fromCache;
  final bool isOnline;
  final DateTime? cacheTimestamp;

  ProductResult._({
    this.products,
    this.error,
    this.fromCache = false,
    this.isOnline = true,
    this.cacheTimestamp,
  });

  factory ProductResult.success(
    List<Product> products, {
    bool fromCache = false,
    bool isOnline = true,
    DateTime? cacheTimestamp,
  }) {
    return ProductResult._(
      products: products,
      fromCache: fromCache,
      isOnline: isOnline,
      cacheTimestamp: cacheTimestamp,
    );
  }

  factory ProductResult.failure(String error, {bool isOnline = false}) {
    return ProductResult._(error: error, isOnline: isOnline);
  }

  bool get isSuccess => products != null;
  bool get isFailure => error != null;

  String get sourceDescription {
    if (fromCache) {
      if (cacheTimestamp != null) {
        final age = DateTime.now().difference(cacheTimestamp!);
        if (age.inHours < 1) {
          return 'Cached (${age.inMinutes} minutes ago)';
        } else if (age.inHours < 24) {
          return 'Cached (${age.inHours} hours ago)';
        } else {
          return 'Cached (${age.inDays} days ago)';
        }
      }
      return 'Cached data';
    }
    return isOnline ? 'Live data' : 'Offline data';
  }
}

class ProductRepository {
  final LocalDataSource _localDataSource = LocalDataSource();
  final FirebaseDataSource _firebaseDataSource = FirebaseDataSource();
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<ProductResult> getProducts() async {
    try {
      // Try to fetch from Firebase first
      final products = await _firebaseDataSource.fetchProducts();

      if (products.isNotEmpty) {
        // Cache the fresh data
        await _localDataSource.cacheProducts(products);
        return ProductResult.success(
          products,
          isOnline: true,
          cacheTimestamp: DateTime.now(),
        );
      }

      // Firebase returned empty, try cache/assets
      return await _getFromCacheOrAssets(hasInternet: true);
    } catch (e) {
      print('Firebase fetch failed: $e');

      // Check if it's a Firebase configuration error
      if (e.toString().contains('Firebase not available') ||
          e.toString().contains('apiKey') ||
          e.toString().contains('appId')) {
        print(
          '⚠️ Firebase configuration issue detected. Falling back to local data.',
        );
      }

      // Firebase failed, check connectivity and fallback
      final isActuallyOnline = _connectivityService.lastKnownState;
      return await _getFromCacheOrAssets(hasInternet: isActuallyOnline);
    }
  }

  Future<ProductResult> _getFromCacheOrAssets({
    required bool hasInternet,
  }) async {
    // Try cache first
    final cachedProducts = await _localDataSource.loadFromCache();
    if (cachedProducts.isNotEmpty) {
      final cacheAge = await _localDataSource.getCacheAge();
      return ProductResult.success(
        cachedProducts,
        fromCache: true,
        isOnline: hasInternet,
        cacheTimestamp: cacheAge != null
            ? DateTime.now().subtract(cacheAge)
            : null,
      );
    }

    // If no cache, try assets
    try {
      final assetsProducts = await _localDataSource.loadFromAssets();
      return ProductResult.success(
        assetsProducts,
        fromCache: false,
        isOnline: hasInternet,
      );
    } catch (e) {
      return ProductResult.failure(
        'No products available. Please check your internet connection.',
        isOnline: hasInternet,
      );
    }
  }

  Future<ProductResult> getProductById(String productId) async {
    try {
      final product = await _firebaseDataSource.fetchProductById(productId);
      if (product != null) {
        return ProductResult.success([product], isOnline: true);
      }
      return ProductResult.failure('Product not found', isOnline: true);
    } catch (e) {
      // Try to find in cached products
      final cachedProducts = await _localDataSource.loadFromCache();
      final cachedProduct = cachedProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => Product(id: '', name: '', price: 0, imageUrl: ''),
      );

      if (cachedProduct.id.isNotEmpty) {
        final cacheAge = await _localDataSource.getCacheAge();
        return ProductResult.success(
          [cachedProduct],
          fromCache: true,
          isOnline: false,
          cacheTimestamp: cacheAge != null
              ? DateTime.now().subtract(cacheAge)
              : null,
        );
      }

      return ProductResult.failure(
        'Product not found. Please check your internet connection.',
        isOnline: false,
      );
    }
  }

  Future<ProductResult> getProductsByCategory(String category) async {
    try {
      final products = await _firebaseDataSource.fetchProductsByCategory(
        category,
      );
      return ProductResult.success(products, isOnline: true);
    } catch (e) {
      // Fallback to filtering cached products
      final cachedProducts = await _localDataSource.loadFromCache();
      final filteredProducts = cachedProducts
          .where((p) => p.category == category)
          .toList();

      if (filteredProducts.isNotEmpty) {
        final cacheAge = await _localDataSource.getCacheAge();
        return ProductResult.success(
          filteredProducts,
          fromCache: true,
          isOnline: false,
          cacheTimestamp: cacheAge != null
              ? DateTime.now().subtract(cacheAge)
              : null,
        );
      }

      return ProductResult.failure(
        'No products found in this category. Please check your internet connection.',
        isOnline: false,
      );
    }
  }

  Stream<List<Product>> get productsStream {
    return _firebaseDataSource.productsStream;
  }

  Stream<bool> get connectivityStream =>
      _connectivityService.connectivityStream;
}
