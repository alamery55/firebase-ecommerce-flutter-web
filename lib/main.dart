import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/firebase_service.dart';
import 'data/services/firestore_seeder_service.dart';
import 'providers/shop_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

/// Entry point of the ShopVibe E-Commerce app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with proper error handling
  try {
    final firebaseInitialized = await FirebaseService.initialize();

    if (firebaseInitialized) {
      debugPrint('✅ Firebase initialized successfully');

      // Seed the database if it's empty (for demo purposes)
      // We don't await this to keep app startup fast
      FirestoreSeederService().seedIfEmpty().then((seeded) {
        if (seeded) debugPrint('✅ Database seeded with initial products');
      }).catchError((e) {
        debugPrint('⚠️ Database seeding error: $e');
      });
    } else {
      debugPrint(
        '⚠️ Firebase initialization failed: ${FirebaseService.initializationError}',
      );
      debugPrint('📱 App will use local data from assets/products.json');
      debugPrint(
        '💡 To enable Firebase, update firebase_options.dart with your actual Firebase configuration',
      );
    }
  } catch (e) {
    debugPrint('❌ Critical Firebase error: $e');
    debugPrint('📱 App will use local data from assets/products.json');
  }

  runApp(const ShopVibeApp());
}

class ShopVibeApp extends StatelessWidget {
  const ShopVibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ShopVibe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
