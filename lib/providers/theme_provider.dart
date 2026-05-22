import 'package:flutter/material.dart';

/// ThemeProvider manages the light/dark mode toggle.
/// Uses ChangeNotifier so the entire app rebuilds when the theme changes.
class ThemeProvider with ChangeNotifier {
  /// Current theme mode — defaults to light
  ThemeMode _themeMode = ThemeMode.light;

  /// Getter for the current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Whether dark mode is currently active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Toggles between light and dark mode
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Sets a specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
