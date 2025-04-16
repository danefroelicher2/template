// lib/database/firestore_helper.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/user_profile.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get workoutsCollection =>
      _firestore.collection('workouts');
  CollectionReference get exercisesCollection =>
      _firestore.collection('exercises');
  CollectionReference get userExercisesCollection =>
      _firestore.collection('userExercises');

  // User methods
  Future<DocumentSnapshot> getUserDocument(String userId) async {
    return await usersCollection.doc(userId).get();
  }

  Future<void> updateUserDocument(
    String userId,
    Map<String, dynamic> data,
  ) async {
    return await usersCollection.doc(userId).update(data);
  }

  // Workout methods
  Future<List<Workout>> getUserWorkouts(String userId) async {
    final snapshot =
        await workoutsCollection
            .where('userId', isEqualTo: userId)
            .orderBy('date', descending: true)
            .get();

    return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
  }

  Future<void> saveWorkout(Workout workout) async {
    // Make sure updatedAt is set
    workout.updatedAt = DateTime.now();

    if (workout.id != null && workout.id!.isNotEmpty) {
      // Update existing workout
      await workoutsCollection.doc(workout.id).update(workout.toFirestoreMap());
    } else {
      // Create new workout
      final docRef = await workoutsCollection.add(workout.toFirestoreMap());
      // This is fine because we've changed id to String? and made it non-final
      workout.id = docRef.id;
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    await workoutsCollection.doc(workoutId).delete();
  }

  // Exercise methods
  Future<List<Exercise>> getExerciseLibrary() async {
    final snapshot = await exercisesCollection.get();
    return snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList();
  }

  Future<List<Exercise>> getUserCustomExercises(String userId) async {
    final snapshot =
        await userExercisesCollection.where('userId', isEqualTo: userId).get();

    return snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList();
  }

  // Firestore utilities
  Future<T> runTransaction<T>(Function(Transaction) updateFunction) async {
    return await _firestore.runTransaction((Transaction transaction) async {
      return await updateFunction(transaction);
    });
  }

  // Batch operations
  Future<void> batchSaveWorkouts(List<Workout> workouts) async {
    final batch = _firestore.batch();

    for (var workout in workouts) {
      // Make sure updatedAt is set
      workout.updatedAt = DateTime.now();

      if (workout.id != null && workout.id!.isNotEmpty) {
        batch.update(
          workoutsCollection.doc(workout.id),
          workout.toFirestoreMap(),
        );
      } else {
        final docRef = workoutsCollection.doc();
        // This is fine because we've changed id to String? and made it non-final
        workout.id = docRef.id;
        batch.set(docRef, workout.toFirestoreMap());
      }
    }

    await batch.commit();
  }
}
