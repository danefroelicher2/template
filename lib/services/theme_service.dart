// lib/services/theme_service.dart - Enhanced implementation
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';

  // Default theme mode
  static const ThemeMode _defaultThemeMode = ThemeMode.system;

  // Private constructor to prevent instantiation
  ThemeService._();

  // Singleton instance
  static final ThemeService instance = ThemeService._();

  // Theme mode notifier
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    _defaultThemeMode,
  );

  // Initialize theme from shared preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt(_themeKey);

    if (savedThemeIndex != null) {
      themeMode.value = ThemeMode.values[savedThemeIndex];
    }
  }

  // Get current theme mode
  ThemeMode get currentThemeMode => themeMode.value;

  // Set theme mode and save to shared preferences
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  // Check if dark mode is active
  bool get isDarkMode {
    if (themeMode.value == ThemeMode.system) {
      // Check system theme
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return themeMode.value == ThemeMode.dark;
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final currentTheme = themeMode.value;

    if (currentTheme == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else if (currentTheme == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      // If system, default to dark
      await setThemeMode(ThemeMode.dark);
    }
  }
}
