// lib/models/exercise.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  String? id; // Changed from int? to String? for Firestore
  final String workoutId; // Changed from int to String for Firestore
  final String name;
  final int sets;
  final int reps;
  final double weight;
  String? userId; // Added for cloud sync
  DateTime? updatedAt; // Added for tracking changes

  Exercise({
    this.id,
    required this.workoutId,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    this.userId,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    // For SQLite
    return {
      'id': id,
      'workout_id': workoutId,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'userId': userId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // For Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'workoutId': workoutId,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'userId': userId,
      'updatedAt':
          updatedAt != null
              ? Timestamp.fromDate(updatedAt!)
              : FieldValue.serverTimestamp(),
    };
  }

  static Exercise fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id']?.toString(), // Convert to String if it's an int
      workoutId: map['workout_id'].toString(), // Convert to String
      name: map['name'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'],
      userId: map['userId'],
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // New method for Firestore
  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Exercise(
      id: doc.id,
      workoutId: data['workoutId'],
      name: data['name'] ?? '',
      sets: data['sets'] ?? 0,
      reps: data['reps'] ?? 0,
      weight: data['weight'] ?? 0.0,
      userId: data['userId'],
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }
}
