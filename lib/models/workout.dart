// lib/models/workout.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  String? id; // Changed from int? to String? for Firestore compatibility
  final String name;
  final DateTime date;
  final String? notes;
  String? userId; // Added for cloud sync
  DateTime? updatedAt; // Added for tracking changes

  Workout({
    this.id,
    required this.name,
    required this.date,
    this.notes,
    this.userId,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    // For SQLite
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'notes': notes,
      'userId': userId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // For Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': name,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'userId': userId,
      'updatedAt':
          updatedAt != null
              ? Timestamp.fromDate(updatedAt!)
              : FieldValue.serverTimestamp(),
    };
  }

  static Workout fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id']?.toString(), // Convert to String if it's an int
      name: map['name'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      userId: map['userId'],
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // New method for Firestore
  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'],
      userId: data['userId'],
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }
}
