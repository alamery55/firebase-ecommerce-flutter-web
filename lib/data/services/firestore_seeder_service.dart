import 'dart:convert';
import 'package:flutter/services.dart';
import '../datasources/firebase_data_source.dart';

class FirestoreSeederService {
  final FirebaseDataSource _firebaseDataSource = FirebaseDataSource();

  Future<bool> seedIfEmpty() async {
    try {
      final hasData = await _firebaseDataSource.hasProducts();
      if (hasData) return false;

      final jsonString = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final products = jsonList.cast<Map<String, dynamic>>();

      await _firebaseDataSource.seedProducts(products);
      return true;
    } catch (e) {
      return false;
    }
  }
}
