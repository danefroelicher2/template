// lib/models/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isGuest;
  final bool isPremium;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? fitnessGoals;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.photoURL,
    this.isGuest = false,
    this.isPremium = false,
    this.createdAt,
    this.lastLogin,
    this.fitnessGoals,
    this.preferences,
  });

  // Create a guest user profile
  factory UserProfile.guest() {
    return UserProfile(
      id: 'guest',
      displayName: 'Guest User',
      isGuest: true,
      isPremium: false,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  // Create from Firebase Auth User
  factory UserProfile.fromFirebase(User user) {
    return UserProfile(
      id: user.uid,
      email: user.email,
      displayName:
          user.displayName ?? user.email?.split('@').first ?? 'Gym User',
      photoURL: user.photoURL,
      isGuest: user.isAnonymous,
    );
  }

  // Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserProfile(
      id: doc.id,
      email: data['email'],
      displayName: data['displayName'] ?? 'Gym User',
      photoURL: data['photoURL'],
      isGuest: data['isGuest'] ?? false,
      isPremium: data['isPremium'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      fitnessGoals: data['fitnessGoals'] as Map<String, dynamic>?,
      preferences: data['preferences'] as Map<String, dynamic>?,
    );
  }

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isGuest': isGuest,
      'isPremium': isPremium,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'fitnessGoals': fitnessGoals,
      'preferences': preferences,
    };
  }

  // Create a copy with updated fields
  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    bool? isGuest,
    bool? isPremium,
    DateTime? lastLogin,
    Map<String, dynamic>? fitnessGoals,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isGuest: isGuest ?? this.isGuest,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      fitnessGoals: fitnessGoals ?? this.fitnessGoals,
      preferences: preferences ?? this.preferences,
    );
  }
}
