import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions is not configured for this platform.',
    );
  }

  // ⚠️ IMPORTANT: These are DEMO credentials for testing only!
  // To use Firebase in production, you MUST replace these with your actual Firebase configuration.
  //
  // Current status: Using demo credentials - Firebase will fail to initialize
  // Expected behavior: App will fallback to local data from assets/products.json
  //
  // To fix Firebase and enable real-time data:
  // 1. Go to https://console.firebase.google.com/
  // 2. Create a new project or select existing
  // 3. Add a web app to your project
  // 4. Copy the configuration from "Add Firebase to your web app"
  // 5. Replace the values in the `web` constant below
  // 6. Enable Cloud Firestore in your Firebase project
  // 7. Create a 'products' collection in Firestore
  // 8. Add documents with the same structure as assets/products.json

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForShopVibe123456789',
    appId: '1:123456789:web:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'shopvibe-ecommerce',
    authDomain: 'shopvibe-ecommerce.firebaseapp.com',
    storageBucket: 'shopvibe-ecommerce.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );
}

/// Firebase configuration instructions for developers
/// 
/// To configure Firebase for your project:
/// 1. Go to https://console.firebase.google.com/
/// 2. Create a new project or select existing
/// 3. Add a web app to your project
/// 4. Copy the configuration from "Add Firebase to your web app"
/// 5. Replace the values in the `web` constant above
/// 
/// Required Firebase services:
/// - Cloud Firestore (for product data)
/// 
/// Security Rules for Firestore:
/// rules_version = '2';
/// service cloud.firestore {
///   match /databases/{database}/documents {
///     match /products/{product} {
///       allow read: if true;
///       allow write: if request.auth != null;
///     }
///   }
/// }