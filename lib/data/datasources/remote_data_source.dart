import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/product.dart';

/// Remote data source for products.
/// Handles API calls and network requests.
class RemoteDataSource {
  // You can replace this with your actual API endpoint
  // For demo purposes, we'll simulate network delay
  static const String _baseUrl = 'https://fakestoreapi.com/products';

  /// Fetch products from remote API
  Future<List<Product>> fetchProducts() async {
    // Simulate network delay for demo
    await Future.delayed(const Duration(milliseconds: 1500));

    // For a real API, use:
    // final response = await http.get(Uri.parse(_baseUrl));
    // if (response.statusCode == 200) {
    //   return _parseProducts(response.body);
    // } else {
    //   throw Exception('Failed to load products: ${response.statusCode}');
    // }

    // Using fakestoreapi as an example (optional)
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      if (response.statusCode == 200) {
        // Transform fakestoreapi format to our format
        return _transformFromFakeStoreApi(response.body);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // If API fails, we'll handle it in the repository
      rethrow;
    }
  }

  /// Transform fakestoreapi response to our Product model
  List<Product> _transformFromFakeStoreApi(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);

    String mapCategory(dynamic rawCat) {
      if (rawCat == null) return 'General';
      final stringCat = rawCat.toString().toLowerCase();
      if (stringCat == 'electronics') return 'Electronics';
      if (stringCat == 'jewelery') return 'Accessories';
      if (stringCat.contains('clothing')) return 'Fashion';
      return _capitalizeFirst(stringCat);
    }

    return jsonList.map((item) {
      return Product(
        id: item['id'].toString(),
        name: item['title'] ?? '',
        price: (item['price'] ?? 0.0).toDouble(),
        imageUrl: item['image'] ?? '',
        category: mapCategory(item['category']),
        description: item['description'] ?? '',
        rating: (item['rating']?['rate'] ?? 0.0).toDouble(),
        ratingCount: (item['rating']?['count'] ?? 0).toInt(),
        inStock: (item['rating']?['rate'] ?? 0) > 0,
        stockQuantity: 50, // Default stock for API products
        brand: 'Brand', // Default brand for API products
        colors: [], // Empty colors for API products
        sizes: [], // Empty sizes for API products
        features: [], // Empty features for API products
        sku: 'API-${item['id']}', // Generate SKU from API ID
      );
    }).toList();
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
