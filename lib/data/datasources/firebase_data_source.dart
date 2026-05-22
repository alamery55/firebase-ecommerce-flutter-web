import '../../models/product.dart';
import '../services/firebase_service.dart';

class FirebaseDataSource {
  static const String _collection = 'products';
  static const int _timeoutSeconds = 10;

  Future<List<Product>> fetchProducts() async {
    try {
      if (!FirebaseService.isAvailable) {
        throw Exception('Firebase not available');
      }

      final snapshot = await FirebaseService.firestore
          .collection(_collection)
          .orderBy('name')
          .get()
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          return Product.fromJson(data);
        } catch (e) {
          print('Error parsing product ${doc.id}: $e');
          return null;
        }
      }).whereType<Product>().toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Product?> fetchProductById(String productId) async {
    try {
      if (!FirebaseService.isAvailable) {
        throw Exception('Firebase not available');
      }

      final doc = await FirebaseService.firestore
          .collection(_collection)
          .doc(productId)
          .get()
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Product.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch product $productId: $e');
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      if (!FirebaseService.isAvailable) {
        throw Exception('Firebase not available');
      }

      final snapshot = await FirebaseService.firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get()
          .timeout(const Duration(seconds: _timeoutSeconds));

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category $category: $e');
    }
  }

  Future<void> seedProducts(List<Map<String, dynamic>> products) async {
    try {
      if (!FirebaseService.isAvailable) {
        throw Exception('Firebase not available');
      }

      final batch = FirebaseService.firestore.batch();
      for (final product in products) {
        final docRef = FirebaseService.firestore
            .collection(_collection)
            .doc(product['id']);
        batch.set(docRef, product);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to seed products: $e');
    }
  }

  Future<bool> hasProducts() async {
    try {
      if (!FirebaseService.isAvailable) {
        return false;
      }

      final snapshot = await FirebaseService.firestore
          .collection(_collection)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: _timeoutSeconds));

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Product>> get productsStream {
    return FirebaseService.firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return Product.fromJson(data);
            } catch (e) {
              print('Error parsing stream product ${doc.id}: $e');
              return null;
            }
          }).whereType<Product>().toList(),
        );
  }
}
