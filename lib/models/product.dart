import 'package:cloud_firestore/cloud_firestore.dart';

/// Product data model for the e-commerce app.
/// Contains all product information including favorite state.
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final String description;
  final double rating;
  final int ratingCount;
  final bool inStock;
  final int stockQuantity;
  final String brand;
  final List<String> colors;
  final List<String> sizes;
  final List<String> features;
  final String sku;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.category = 'General',
    this.description = '',
    this.rating = 0.0,
    this.ratingCount = 0,
    this.inStock = true,
    this.stockQuantity = 0,
    this.brand = '',
    this.colors = const [],
    this.sizes = const [],
    this.features = const [],
    this.sku = '',
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: (json['ratingCount'] ?? 0).toInt(),
      inStock: json['inStock'] ?? true,
      stockQuantity: (json['stockQuantity'] ?? 0).toInt(),
      brand: json['brand'] ?? '',
      colors: List<String>.from(json['colors'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      sku: json['sku'] ?? '',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'rating': rating,
      'ratingCount': ratingCount,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
      'brand': brand,
      'colors': colors,
      'sizes': sizes,
      'features': features,
      'sku': sku,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  /// Get availability status with color
  String get availabilityStatus {
    if (!inStock) return 'Out of Stock';
    if (stockQuantity <= 0) return 'Out of Stock';
    if (stockQuantity < 10) return 'Low Stock';
    return 'In Stock';
  }

  /// Get availability color
  String get availabilityColor {
    if (!inStock || stockQuantity <= 0) return 'error';
    if (stockQuantity < 10) return 'warning';
    return 'success';
  }

  /// Get formatted rating with count
  String get formattedRating {
    return '$rating ($ratingCount reviews)';
  }

  /// Get stock status text
  String get stockStatus {
    if (!inStock) return 'Out of Stock';
    if (stockQuantity <= 0) return 'Out of Stock';
    if (stockQuantity < 10) return 'Only $stockQuantity left';
    return '$stockQuantity in stock';
  }
}
