// lib/providers/auth_provider.dart
// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && !_user!.isAnonymous;
  bool get isGuest => _user != null && _user!.isAnonymous;

  // Initialize and listen to auth state changes
  Future<void> initialize() async {
    _setLoading(true);

    try {
      print("Initializing AuthProvider");

      // Listen to auth state changes
      _authService.authStateChanges.listen(
        (User? user) {
          print(
            "Auth state changed: ${user != null ? 'User logged in' : 'No user'}",
          );
          _user = user;
          _loadUserProfile();
          notifyListeners();
        },
        onError: (error) {
          print("Auth state error: $error");
          _setError(error.toString());
        },
      );

      print("Auth listener initialized");
    } catch (e) {
      print("Auth initialization error: $e");
      _setError(e.toString());
    }

    _setLoading(false);
  }

  // Load user profile
  Future<void> _loadUserProfile() async {
    if (_user != null) {
      try {
        print("Loading user profile for user: ${_user!.uid}");
        _profile = await _authService.getUserProfile();
        print("Profile loaded successfully");
        notifyListeners();
      } catch (e) {
        print("Error loading profile: $e");
        _setError(e.toString());
      }
    } else {
      _profile = null;
    }
  }

  // Sign up with email
  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signUpWithEmail(email, password);

      // Reset onboarding completion status to force onboarding for new users
      await _resetOnboardingStatus();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign in with email
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signInWithEmail(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential = await _authService.signInWithGoogle();

      // Check if this is a new account (first sign-in)
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Reset onboarding completion status to force onboarding
        await _resetOnboardingStatus();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign in as guest
  Future<bool> signInAsGuest() async {
    _setLoading(true);
    _clearError();

    try {
      print("Attempting to sign in as guest...");
      await _authService.signInAnonymously();
      print("Guest sign-in successful");

      // Reset onboarding completion status to force onboarding for guest users
      await _resetOnboardingStatus();

      _setLoading(false);
      return true;
    } catch (e) {
      print("Guest sign-in error: $e");
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Convert guest to permanent account
  Future<bool> convertGuestAccount(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.convertGuestAccount(email, password);
      await _loadUserProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
    String? fitnessGoal,
    int? experienceLevel,
    List<bool>? workoutDays,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Save fitness preferences if provided
      if (fitnessGoal != null ||
          experienceLevel != null ||
          workoutDays != null) {
        final prefs = await SharedPreferences.getInstance();

        if (fitnessGoal != null) {
          await prefs.setString('fitness_goal', fitnessGoal);
        }

        if (experienceLevel != null) {
          await prefs.setInt('experience_level', experienceLevel);
        }

        if (workoutDays != null) {
          await prefs.setStringList(
            'workout_days',
            workoutDays
                .asMap()
                .entries
                .where((entry) => entry.value)
                .map((entry) => entry.key.toString())
                .toList(),
          );
        }
      }

      await _loadUserProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Add to AuthProvider class
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteAccount();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset onboarding status to force onboarding for new sign-ins
  Future<void> _resetOnboardingStatus() async {
    try {
      print("Resetting onboarding status to show onboarding");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', false);
    } catch (e) {
      print('Failed to reset onboarding status: $e');
    }
  }
}
