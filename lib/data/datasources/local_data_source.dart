import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product.dart';

/// Local data source for products with enhanced caching and offline support
class LocalDataSource {
  static const String _cacheKey = 'cached_products';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const Duration _cacheValidityDuration = Duration(hours: 24);

  /// Load products from local assets (mock JSON file)
  Future<List<Product>> loadFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/products.json',
      );
      return _parseProducts(jsonString);
    } catch (e) {
      throw Exception('Failed to load products from assets: $e');
    }
  }

  /// Load products from SharedPreferences cache with timestamp validation
  Future<List<Product>> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (cachedData != null && timestamp != null) {
        final cacheAge = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(timestamp),
        );

        // Check if cache is still valid
        if (cacheAge <= _cacheValidityDuration) {
          return _parseProducts(cachedData);
        } else {
          // Cache expired, clear it
          await clearCache();
        }
      }
      return [];
    } catch (e) {
      // If cache is corrupted, clear it
      await clearCache();
      return [];
    }
  }

  /// Save products to cache with timestamp
  Future<void> cacheProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = products.map((p) => p.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw Exception('Failed to cache products: $e');
    }
  }

  /// Parse JSON string to Product list with error handling
  List<Product> _parseProducts(String jsonString) {
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to parse cached products: $e');
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (e) {
      // Ignore errors when clearing cache
    }
  }

  /// Check if cache exists and is valid
  Future<bool> hasValidCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (cachedData != null && timestamp != null) {
        final cacheAge = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(timestamp),
        );
        return cacheAge <= _cacheValidityDuration;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get cache age
  Future<Duration?> getCacheAge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (timestamp != null) {
        return DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(timestamp),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
