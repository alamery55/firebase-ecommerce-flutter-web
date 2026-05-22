import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product.dart';
import '../datasources/firebase_data_source.dart';
import '../datasources/local_data_source.dart';
import 'connectivity_service.dart';

class ProductDetailsService {
  final LocalDataSource _localDataSource = LocalDataSource();
  final FirebaseDataSource _firebaseDataSource = FirebaseDataSource();
  final ConnectivityService _connectivityService = ConnectivityService();

  static const String _productCacheKey = 'cached_product_';
  static const String _productCacheTimestampKey = 'cached_product_timestamp_';
  static const Duration _cacheDuration = Duration(hours: 24);

  Future<ProductDetailsResult> getProductDetails(String productId) async {
    try {
      final hasInternet = await _connectivityService.hasInternetConnection();

      if (hasInternet) {
        try {
          final product = await _firebaseDataSource.fetchProductById(productId);
          
          if (product != null) {
            await _cacheProduct(product);
            return ProductDetailsResult.success(
              product: product,
              source: DataSource.network,
              isOnline: true,
            );
          } else {
            throw Exception('Product not found in database');
          }
        } catch (e) {
          return await _getFromCache(productId, hasInternet: false);
        }
      } else {
        return await _getFromCache(productId, hasInternet: false);
      }
    } catch (e) {
      return await _getFromAssets(productId);
    }
  }

  Future<ProductDetailsResult> _getFromCache(
    String productId, {
    required bool hasInternet,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('$_productCacheKey$productId');
    final timestampStr = prefs.getString('$_productCacheTimestampKey$productId');

    if (cachedData != null && timestampStr != null) {
      final timestamp = DateTime.tryParse(timestampStr);
      final now = DateTime.now();

      if (timestamp != null && now.difference(timestamp) < _cacheDuration) {
        try {
          final product = Product.fromJson(json.decode(cachedData));
          return ProductDetailsResult.success(
            product: product,
            source: DataSource.cache,
            isOnline: hasInternet,
          );
        } catch (e) {
          return await _getFromAssets(productId);
        }
      }
    }

    return await _getFromAssets(productId);
  }

  Future<ProductDetailsResult> _getFromAssets(String productId) async {
    try {
      final products = await _localDataSource.loadFromAssets();
      final product = products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found in assets'),
      );

      return ProductDetailsResult.success(
        product: product,
        source: DataSource.assets,
        isOnline: false,
      );
    } catch (e) {
      return ProductDetailsResult.failure(
        error: 'Product not available offline',
        isOnline: false,
      );
    }
  }

  Future<void> _cacheProduct(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(product.toJson());
    final now = DateTime.now().toIso8601String();

    await prefs.setString('$_productCacheKey${product.id}', jsonString);
    await prefs.setString('$_productCacheTimestampKey${product.id}', now);
  }

  Future<void> clearProductCache(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_productCacheKey$productId');
    await prefs.remove('$_productCacheTimestampKey$productId');
  }

  Future<void> clearAllProductCaches() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) =>
        key.startsWith(_productCacheKey) ||
        key.startsWith(_productCacheTimestampKey)).toList();

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  Stream<bool> get connectivityStream => _connectivityService.connectivityStream;
}

enum DataSource { network, cache, assets }

class ProductDetailsResult {
  final Product? product;
  final String? error;
  final DataSource? source;
  final bool isOnline;
  final bool fromCache;

  ProductDetailsResult._({
    this.product,
    this.error,
    this.source,
    this.isOnline = true,
    this.fromCache = false,
  });

  factory ProductDetailsResult.success({
    required Product product,
    required DataSource source,
    required bool isOnline,
  }) {
    return ProductDetailsResult._(
      product: product,
      source: source,
      isOnline: isOnline,
      fromCache: source == DataSource.cache,
    );
  }

  factory ProductDetailsResult.failure({
    required String error,
    required bool isOnline,
  }) {
    return ProductDetailsResult._(error: error, isOnline: isOnline);
  }

  bool get isSuccess => product != null;
  bool get isFailure => error != null;

  String get sourceDescription {
    switch (source) {
      case DataSource.network:
        return 'Live data';
      case DataSource.cache:
        return 'Cached data';
      case DataSource.assets:
        return 'Offline data';
      default:
        return 'Unknown source';
    }
  }
}
