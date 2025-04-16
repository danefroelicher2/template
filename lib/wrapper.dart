import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/main_navigation.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    print(
      "Wrapper - User: ${authProvider.user}, isGuest: ${authProvider.isGuest}",
    );

    // Show loading spinner when initializing
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Navigate based on auth state
    if (authProvider.user != null) {
      print("User is authenticated, navigating to main app");
      return MainNavigation();
    } else {
      print("No user found, navigating to welcome screen");
      return WelcomeScreen();
    }
  }
}
