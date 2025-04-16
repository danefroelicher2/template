// lib/services/subscription_service.dart

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class SubscriptionService {
  static final AuthService _authService = AuthService();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user has premium access
  static Future<bool> isPremium() async {
    // For guest or offline users, check local storage
    if (!_authService.isAuthenticated) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_premium') ?? false;
    }

    // For authenticated users, check Firestore
    try {
      final doc =
          await _firestore.collection('users').doc(_authService.userId).get();
      return doc.data()?['isPremium'] ?? false;
    } catch (e) {
      // If offline or error, fall back to local storage
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_premium') ?? false;
    }
  }

  // Update premium status
  static Future<void> updatePremiumStatus(bool isPremium) async {
    // Update local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', isPremium);

    // Update Firestore if authenticated
    if (_authService.isAuthenticated) {
      await _firestore.collection('users').doc(_authService.userId).update({
        'isPremium': isPremium,
        'premiumUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<bool> upgradeToPremium() async {
    try {
      // In a real app, this would integrate with in-app purchases
      // For now, just update the status to premium
      await updatePremiumStatus(true);
      return true;
    } catch (e) {
      print('Error upgrading to premium: $e');
      return false;
    }
  }

  // Get available premium features
  static List<PremiumFeature> getAvailablePremiumFeatures() {
    return [
      PremiumFeature(
        title: 'Cloud Sync',
        description: 'Sync your workouts across all your devices',
        icon: 'sync',
      ),
      PremiumFeature(
        title: 'Advanced Analytics',
        description: 'Get detailed insights into your workout performance',
        icon: 'analytics',
      ),
      PremiumFeature(
        title: 'Unlimited Workout History',
        description: 'Never lose your workout history',
        icon: 'history',
      ),
      PremiumFeature(
        title: 'Custom Exercise Creation',
        description: 'Create and save your own exercises',
        icon: 'create',
      ),
      PremiumFeature(
        title: 'Ad-Free Experience',
        description: 'Enjoy GymTracker Pro without advertisements',
        icon: 'block',
      ),
    ];
  }
}

// Premium feature model
class PremiumFeature {
  final String title;
  final String description;
  final String icon;

  PremiumFeature({
    required this.title,
    required this.description,
    required this.icon,
  });
}
