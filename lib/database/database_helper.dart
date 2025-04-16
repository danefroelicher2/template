// lib/database/database_helper.dart
import 'package:gym/models/workout.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

class DatabaseHelper {
  static final _databaseName = "gymtracker.db";
  static final _databaseVersion = 1;

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // In-memory data for web platform
  static final Map<String, List<Map<String, dynamic>>> _webData = {
    'workouts': [],
    'exercises': [],
    'preset_exercises': [
      {'id': 1, 'name': 'Bench Press', 'category': 'Chest', 'is_premium': 0},
      {'id': 2, 'name': 'Push-ups', 'category': 'Chest', 'is_premium': 0},
      {'id': 3, 'name': 'Dumbbell Flyes', 'category': 'Chest', 'is_premium': 0},
      {'id': 4, 'name': 'Pull-ups', 'category': 'Back', 'is_premium': 0},
      {'id': 5, 'name': 'Bent-over Rows', 'category': 'Back', 'is_premium': 0},
      {'id': 6, 'name': 'Lat Pulldowns', 'category': 'Back', 'is_premium': 0},
      {'id': 7, 'name': 'Squats', 'category': 'Legs', 'is_premium': 0},
      {'id': 8, 'name': 'Lunges', 'category': 'Legs', 'is_premium': 0},
      {'id': 9, 'name': 'Leg Press', 'category': 'Legs', 'is_premium': 0},
      {
        'id': 10,
        'name': 'Incline Bench Press',
        'category': 'Chest',
        'is_premium': 1,
      },
      {
        'id': 11,
        'name': 'Cable Crossovers',
        'category': 'Chest',
        'is_premium': 1,
      },
      {'id': 12, 'name': 'Deadlifts', 'category': 'Back', 'is_premium': 1},
      {'id': 13, 'name': 'T-Bar Rows', 'category': 'Back', 'is_premium': 1},
      {'id': 14, 'name': 'Hack Squats', 'category': 'Legs', 'is_premium': 1},
      {
        'id': 15,
        'name': 'Romanian Deadlifts',
        'category': 'Legs',
        'is_premium': 1,
      },
    ],
  };

  Future<Database> get database async {
    // For web, we'll use a mock database
    if (kIsWeb) {
      if (_database != null) return _database!;
      // Create a delay to simulate database initialization
      await Future.delayed(Duration(milliseconds: 100));
      return Future.value(null as Database);
    } else {
      // For mobile platforms, use actual SQLite
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    }
  }

  // Update tables schema to support cloud sync
  Future<void> _updateSchema(Database db) async {
    // Add userId field to workouts table
    await db.execute('ALTER TABLE workouts ADD COLUMN userId TEXT');

    // Add updatedAt field to workouts table
    await db.execute('ALTER TABLE workouts ADD COLUMN updatedAt TEXT');

    // Add updatedAt field to exercises table
    await db.execute('ALTER TABLE exercises ADD COLUMN updatedAt TEXT');
  }

  // Get all workouts
  Future<List<Workout>> getAllWorkouts() async {
    if (kIsWeb) {
      // For web, use in-memory data
      return _webData['workouts']?.map((w) => Workout.fromMap(w)).toList() ??
          [];
    } else {
      final db = await database;
      final workoutMaps = await db.query('workouts');
      return workoutMaps.map((w) => Workout.fromMap(w)).toList();
    }
  }

  // Get workouts modified since a specific date
  Future<List<Workout>> getWorkoutsModifiedSince(DateTime? timestamp) async {
    if (kIsWeb) {
      // For web, use in-memory data
      if (timestamp == null) {
        return _webData['workouts']?.map((w) => Workout.fromMap(w)).toList() ??
            [];
      }

      return _webData['workouts']
              ?.where((w) {
                if (w['updatedAt'] == null) return true;
                return DateTime.parse(w['updatedAt']).isAfter(timestamp);
              })
              .map((w) => Workout.fromMap(w))
              .toList() ??
          [];
    } else {
      final db = await database;

      if (timestamp == null) {
        final workoutMaps = await db.query('workouts');
        return workoutMaps.map((w) => Workout.fromMap(w)).toList();
      }

      final workoutMaps = await db.query(
        'workouts',
        where: 'updatedAt > ?',
        whereArgs: [timestamp.toIso8601String()],
      );

      return workoutMaps.map((w) => Workout.fromMap(w)).toList();
    }
  }

  // Save workout with cloud sync support
  Future<void> saveWorkout(Workout workout) async {
    // Set updatedAt timestamp
    workout.updatedAt = DateTime.now();

    if (kIsWeb) {
      // For web, use in-memory data
      if (workout.id != null) {
        // Update existing workout
        final index =
            _webData['workouts']?.indexWhere((w) => w['id'] == workout.id) ??
            -1;
        if (index >= 0) {
          _webData['workouts']?[index] = workout.toMap();
        }
      } else {
        // Create new workout with string ID
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        workout.id = id;
        _webData['workouts']?.add({...workout.toMap(), 'id': id});
      }
    } else {
      final db = await database;

      if (workout.id != null) {
        // Update existing workout
        await db.update(
          'workouts',
          workout.toMap(),
          where: 'id = ?',
          whereArgs: [workout.id],
        );
      } else {
        // Create a new workout with string ID
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        workout.id = id;
        await db.insert('workouts', {...workout.toMap(), 'id': id});
      }
    }
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''');

    // Create preset exercises table
    await db.execute('''
      CREATE TABLE preset_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        is_premium INTEGER DEFAULT 0
      )
    ''');

    // Insert sample preset exercises
    await _insertSampleExercises(db);
  }

  Future _insertSampleExercises(Database db) async {
    // Free exercises
    var batch = db.batch();

    // Chest exercises
    batch.insert('preset_exercises', {
      'name': 'Bench Press',
      'category': 'Chest',
      'is_premium': 0,
    });
    batch.insert('preset_exercises', {
      'name': 'Push-ups',
      'category': 'Chest',
      'is_premium': 0,
    });
    batch.insert('preset_exercises', {
      'name': 'Dumbbell Flyes',
      'category': 'Chest',
      'is_premium': 0,
    });

    // Back exercises
    batch.insert('preset_exercises', {
      'name': 'Pull-ups',
      'category': 'Back',
      'is_premium': 0,
    });
    batch.insert('preset_exercises', {
      'name': 'Bent-over Rows',
      'category': 'Back',
      'is_premium': 0,
    });
    batch.insert('preset_exercises', {
      'name': 'Lat Pulldowns',
      'category': 'Back',
      'is_premium': 0,
    });

    // Legs exercises
    batch.insert('preset_exercises', {
      'name': 'Squats',
      'category': 'Legs',
      'is_premium': 0,
    });
    batch.insert('preset_exercises', {
      'name': 'Lunges',
      'category': 'Legs',
      'is_premium': 0,
    });
    batch.insert('preset_exercises', {
      'name': 'Leg Press',
      'category': 'Legs',
      'is_premium': 0,
    });

    // Premium exercises
    batch.insert('preset_exercises', {
      'name': 'Incline Bench Press',
      'category': 'Chest',
      'is_premium': 1,
    });
    batch.insert('preset_exercises', {
      'name': 'Cable Crossovers',
      'category': 'Chest',
      'is_premium': 1,
    });
    batch.insert('preset_exercises', {
      'name': 'Deadlifts',
      'category': 'Back',
      'is_premium': 1,
    });
    batch.insert('preset_exercises', {
      'name': 'T-Bar Rows',
      'category': 'Back',
      'is_premium': 1,
    });
    batch.insert('preset_exercises', {
      'name': 'Hack Squats',
      'category': 'Legs',
      'is_premium': 1,
    });
    batch.insert('preset_exercises', {
      'name': 'Romanian Deadlifts',
      'category': 'Legs',
      'is_premium': 1,
    });

    await batch.commit();
  }

  // CRUD operations for workouts
  Future<int> insertWorkout(Map<String, dynamic> workout) async {
    if (kIsWeb) {
      // For web, use in-memory data
      int id = (_webData['workouts']?.length ?? 0) + 1;
      workout['id'] = id;
      _webData['workouts']?.add(workout);
      return id;
    } else {
      Database db = await database;
      return await db.insert('workouts', workout);
    }
  }

  Future<List<Map<String, dynamic>>> getWorkouts() async {
    if (kIsWeb) {
      // For web, use in-memory data
      return _webData['workouts'] ?? [];
    } else {
      Database db = await database;
      return await db.query('workouts', orderBy: 'date DESC');
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutsByDate(DateTime date) async {
    if (kIsWeb) {
      // For web, use in-memory data
      String dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      return _webData['workouts']
              ?.where(
                (workout) => (workout['date'] as String).startsWith(dateStr),
              )
              .toList() ??
          [];
    } else {
      Database db = await database;
      String dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      return await db.query(
        'workouts',
        where: 'date LIKE ?',
        whereArgs: ['$dateStr%'],
      );
    }
  }

  // CRUD operations for exercises
  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    if (kIsWeb) {
      // For web, use in-memory data
      int id = (_webData['exercises']?.length ?? 0) + 1;
      exercise['id'] = id;
      _webData['exercises']?.add(exercise);
      return id;
    } else {
      Database db = await database;
      return await db.insert('exercises', exercise);
    }
  }

  Future<List<Map<String, dynamic>>> getExercisesForWorkout(
    int workoutId,
  ) async {
    if (kIsWeb) {
      // For web, use in-memory data
      return _webData['exercises']
              ?.where((exercise) => exercise['workout_id'] == workoutId)
              .toList() ??
          [];
    } else {
      Database db = await database;
      return await db.query(
        'exercises',
        where: 'workout_id = ?',
        whereArgs: [workoutId],
      );
    }
  }

  // Operations for preset exercises
  Future<List<Map<String, dynamic>>> getPresetExercises(bool isPremium) async {
    if (kIsWeb) {
      // For web, use in-memory data
      if (isPremium) {
        return _webData['preset_exercises'] ?? [];
      } else {
        return _webData['preset_exercises']
                ?.where((exercise) => exercise['is_premium'] == 0)
                .toList() ??
            [];
      }
    } else {
      Database db = await database;
      if (isPremium) {
        // If premium, get all exercises
        return await db.query('preset_exercises', orderBy: 'category, name');
      } else {
        // If free, get only free exercises
        return await db.query(
          'preset_exercises',
          where: 'is_premium = ?',
          whereArgs: [0],
          orderBy: 'category, name',
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> getPresetExercisesByCategory(
    String category,
    bool isPremium,
  ) async {
    if (kIsWeb) {
      // For web, use in-memory data
      if (isPremium) {
        return _webData['preset_exercises']
                ?.where((exercise) => exercise['category'] == category)
                .toList() ??
            [];
      } else {
        return _webData['preset_exercises']
                ?.where(
                  (exercise) =>
                      exercise['category'] == category &&
                      exercise['is_premium'] == 0,
                )
                .toList() ??
            [];
      }
    } else {
      Database db = await database;
      if (isPremium) {
        return await db.query(
          'preset_exercises',
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'name',
        );
      } else {
        return await db.query(
          'preset_exercises',
          where: 'category = ? AND is_premium = ?',
          whereArgs: [category, 0],
          orderBy: 'name',
        );
      }
    }
  }

  // New methods for Progress and Profile pages
  Future<List<Map<String, dynamic>>> getRecentWorkouts(int limit) async {
    if (kIsWeb) {
      // For web, use in-memory data
      var workouts = _webData['workouts'] ?? [];
      if (workouts.length > limit) {
        return workouts.sublist(0, limit);
      }
      return workouts;
    } else {
      Database db = await database;
      return await db.query('workouts', orderBy: 'date DESC', limit: limit);
    }
  }

  Future<List<Map<String, dynamic>>> getAllExercises() async {
    if (kIsWeb) {
      // For web, use in-memory data
      return _webData['exercises'] ?? [];
    } else {
      Database db = await database;
      return await db.query('exercises');
    }
  }

  // Get workouts with is_tracked flag
  Future<List<Map<String, dynamic>>> getTrackedWorkouts() async {
    if (kIsWeb) {
      // For web, use in-memory data
      return _webData['workouts']
              ?.where((w) => w['is_tracked'] == 1)
              .toList() ??
          [];
    } else {
      Database db = await database;
      return await db.query(
        'workouts',
        where: 'is_tracked = ?',
        whereArgs: [1],
        orderBy: 'date DESC',
      );
    }
  }

  // NEW METHODS FOR PROGRESS CHARTS

  // Get exercise progress data for charts
  Future<List<Map<String, dynamic>>> getExerciseProgressData(
    String exerciseName,
  ) async {
    if (kIsWeb) {
      // For web, simulate with in-memory data
      List<Map<String, dynamic>> result = [];

      // Get all exercises with the given name
      final exercises =
          _webData['exercises']
              ?.where((exercise) => exercise['name'] == exerciseName)
              .toList() ??
          [];

      // Join with workout data to get dates
      for (var exercise in exercises) {
        final workoutId = exercise['workout_id'] as int;
        final workout = _webData['workouts']?.firstWhere(
          (w) => w['id'] == workoutId,
          orElse: () => {},
        );

        // Fix: Check if the workout map is not empty instead of using isNotEmpty
        if (workout != null && workout.isNotEmpty) {
          result.add({'weight': exercise['weight'], 'date': workout['date']});
        }
      }

      // Sort by date
      result.sort(
        (a, b) => (a['date'] as String).compareTo(b['date'] as String),
      );
      return result;
    } else {
      Database db = await database;

      // This query joins workouts and exercises tables to get the exercise weight
      // progression over time for a specific exercise
      final List<Map<String, dynamic>> results = await db.rawQuery(
        '''
        SELECT e.weight, w.date
        FROM exercises e
        JOIN workouts w ON e.workout_id = w.id
        WHERE e.name = ?
        ORDER BY w.date ASC
      ''',
        [exerciseName],
      );

      return results;
    }
  }

  // Get top exercises by frequency
  Future<List<String>> getTopExercises(int limit) async {
    if (kIsWeb) {
      // For web, simulate with in-memory data
      Map<String, int> exerciseCounts = {};

      // Count occurrences of each exercise
      for (var exercise in _webData['exercises'] ?? []) {
        final name = exercise['name'] as String;
        exerciseCounts[name] = (exerciseCounts[name] ?? 0) + 1;
      }

      // Convert to list of entries for sorting
      final entries =
          exerciseCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      // Take only the top ones
      final topExercises = entries.take(limit).map((e) => e.key).toList();
      return topExercises;
    } else {
      final db = await database;

      final List<Map<String, dynamic>> results = await db.rawQuery(
        '''
        SELECT name, COUNT(*) as count
        FROM exercises
        GROUP BY name
        ORDER BY count DESC
        LIMIT ?
      ''',
        [limit],
      );

      return results.map((e) => e['name'] as String).toList();
    }
  }
}
