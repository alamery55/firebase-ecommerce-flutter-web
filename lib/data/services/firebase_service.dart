import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart';

/// Firebase service for initializing and managing Firebase connections
class FirebaseService {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static String? _initializationError;
  static String? get initializationError => _initializationError;

  /// Initialize Firebase with proper error handling
  static Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      print('Initializing Firebase...');

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      print('Firebase initialized successfully');

      // Test Firestore connection
      await _testFirestoreConnection();

      _initialized = true;
      _initializationError = null;
      return true;
    } catch (e) {
      _initializationError = e.toString();
      print('Firebase initialization failed: $e');

      // Check if it's a configuration error
      if (e.toString().contains('apiKey') ||
          e.toString().contains('appId') ||
          e.toString().contains('projectId')) {
        print(
          '⚠️ Firebase configuration error detected. Using demo credentials?',
        );
        print(
          'Please update firebase_options.dart with your actual Firebase configuration.',
        );
      }

      return false;
    }
  }

  /// Test Firestore connection by making a simple query
  static Future<void> _testFirestoreConnection() async {
    try {
      final firestore = FirebaseFirestore.instance;
      // Use a very short timeout for the initial connection test
      await firestore.collection('products').limit(1).get().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Firestore connection timed out'),
      );
    } catch (e) {
      print('Firestore connection test warning: $e');
      // We don't rethrow here to allow the app to start in offline mode if Firestore is slow
    }
  }

  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (!_initialized) {
      throw Exception(
        'Firebase not initialized. Call FirebaseService.initialize() first.',
      );
    }
    return FirebaseFirestore.instance;
  }

  /// Check if Firebase is available
  static bool get isAvailable => _initialized && _initializationError == null;
}
