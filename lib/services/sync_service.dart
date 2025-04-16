// lib/services/sync_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../database/firestore_helper.dart';
import '../models/workout.dart';
import 'auth_service.dart';
import 'subscription_service.dart';

class SyncService {
  final AuthService _authService = AuthService();
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Last sync timestamp key for SharedPreferences
  static const String _lastSyncKey = 'last_sync_timestamp';

  // Check if user can sync (premium only)
  Future<bool> canSync() async {
    if (!_authService.isAuthenticated) return false;
    return await SubscriptionService.isPremium();
  }

  // Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // Update last sync timestamp
  Future<void> updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Sync workouts (both directions)
  Future<void> syncWorkouts() async {
    if (!await canSync()) return;

    final userId = _authService.userId;
    final lastSync = await getLastSyncTime();

    // Get local workouts modified since last sync
    final localWorkouts = await _databaseHelper.getWorkoutsModifiedSince(
      lastSync,
    );

    // Upload local changes to Firestore
    if (localWorkouts.isNotEmpty) {
      for (var workout in localWorkouts) {
        // Make sure workout has userId set
        workout.userId = userId;
        await _firestoreHelper.saveWorkout(workout);
      }
    }

    // Get cloud workouts modified since last sync
    final cloudWorkouts = await _getCloudWorkoutsModifiedSince(lastSync);

    // Download cloud changes to local DB
    if (cloudWorkouts.isNotEmpty) {
      for (var workout in cloudWorkouts) {
        await _databaseHelper.saveWorkout(workout);
      }
    }

    // Update last sync timestamp
    await updateLastSyncTime();
  }

  // Get cloud workouts modified since a specific timestamp
  Future<List<Workout>> _getCloudWorkoutsModifiedSince(
    DateTime? timestamp,
  ) async {
    final userId = _authService.userId;

    Query query = _firestoreHelper.workoutsCollection.where(
      'userId',
      isEqualTo: userId,
    );

    if (timestamp != null) {
      query = query.where(
        'updatedAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(timestamp),
      );
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
  }

  // Full sync (for first-time sync or manual sync)
  Future<void> fullSync() async {
    if (!await canSync()) return;

    final userId = _authService.userId;

    // Get all local workouts
    final localWorkouts = await _databaseHelper.getAllWorkouts();

    // Upload all local workouts
    for (var workout in localWorkouts) {
      workout.userId = userId;
      await _firestoreHelper.saveWorkout(workout);
    }

    // Get all cloud workouts
    final cloudWorkouts = await _firestoreHelper.getUserWorkouts(userId);

    // Download all cloud workouts
    for (var workout in cloudWorkouts) {
      await _databaseHelper.saveWorkout(workout);
    }

    // Update last sync timestamp
    await updateLastSyncTime();
  }

  // Handle conflicts (simplest strategy: newest wins)
  Future<Workout> resolveWorkoutConflict(
    Workout localWorkout,
    Workout cloudWorkout,
  ) async {
    if (localWorkout.updatedAt == null && cloudWorkout.updatedAt == null) {
      localWorkout.updatedAt = DateTime.now();
      return localWorkout;
    } else if (localWorkout.updatedAt == null) {
      return cloudWorkout;
    } else if (cloudWorkout.updatedAt == null) {
      return localWorkout;
    }

    // Compare timestamps and return the newest
    if (localWorkout.updatedAt!.isAfter(cloudWorkout.updatedAt!)) {
      return localWorkout;
    } else {
      return cloudWorkout;
    }
  }
}
