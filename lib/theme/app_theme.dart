// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Light theme
  static ThemeData lightTheme = ThemeData(
    // Base theme
    brightness: Brightness.light,

    // Colors
    primaryColor: Colors.blue,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.teal,
      tertiary: Colors.amber,
      surface: Colors.white,
      background: Color(0xFFF5F5F5),
      error: Colors.red,
    ),

    // Scaffolds and backgrounds
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    cardColor: Colors.white,

    // Text
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
      bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
    ),

    // Input decorations
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        side: BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    ),

    // Cards
    cardTheme: CardTheme(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: Colors.white,
      margin: EdgeInsets.all(8.0),
    ),

    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    // Bottom navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
    ),

    // Tab bar
    tabBarTheme: TabBarTheme(
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue,
    ),

    // Visual density for all widgets
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    // Base theme
    brightness: Brightness.dark,

    // Colors
    primaryColor: Colors.blue[700],
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.dark(
      primary: Colors.blue[700]!,
      secondary: Colors.tealAccent,
      tertiary: Colors.amberAccent,
      surface: Color(0xFF303030),
      background: Color(0xFF121212),
      error: Colors.redAccent,
    ),

    // Scaffolds and backgrounds
    scaffoldBackgroundColor: Color(0xFF121212),
    cardColor: Color(0xFF1E1E1E),

    // Text
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      bodySmall: TextStyle(fontSize: 12, color: Colors.white54),
    ),

    // Input decorations
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue[700]!, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      filled: true,
      fillColor: Color(0xFF303030),
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue[400],
        side: BorderSide(color: Colors.blue[400]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue[400],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    ),

    // Cards
    cardTheme: CardTheme(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.all(8.0),
    ),

    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    // Bottom navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Colors.blue[400],
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
    ),

    // Tab bar
    tabBarTheme: TabBarTheme(
      labelColor: Colors.blue[400],
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue[400],
    ),

    // Visual density for all widgets
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
