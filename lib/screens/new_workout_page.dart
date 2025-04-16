// lib/screens/new_workout_page.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/subscription_service.dart';

class NewWorkoutPage extends StatefulWidget {
  const NewWorkoutPage({super.key});

  @override
  _NewWorkoutPageState createState() => _NewWorkoutPageState();
}

class _NewWorkoutPageState extends State<NewWorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _workoutNameController = TextEditingController();
  final _searchController = TextEditingController();
  final _notesController = TextEditingController(); // Added missing controller

  final List<Map<String, dynamic>> _exercises = [];
  bool _isPremium = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // Map to store exercises by category
  final Map<String, List<Map<String, dynamic>>> _exercisesByCategory = {};
  // All exercises in a flat list for searching
  final List<Map<String, dynamic>> _allExercises = [];

  // Big 3 muscle groups
  final List<Map<String, dynamic>> _bigThreeMuscleGroups = [
    {
      'name': 'Chest',
      'image': 'assets/chest.png', // You would need to add these image assets
      'color': Colors.red.shade200,
    },
    {'name': 'Back', 'image': 'assets/back.png', 'color': Colors.blue.shade200},
    {
      'name': 'Legs',
      'image': 'assets/legs.png',
      'color': Colors.green.shade200,
    },
  ];

  // Boring muscle groups
  final List<Map<String, dynamic>> _boringMuscleGroups = [
    {
      'name': 'Shoulders',
      'image': 'assets/shoulders.png',
      'color': Colors.orange.shade200,
    },
    {
      'name': 'Arms',
      'image': 'assets/arms.png',
      'color': Colors.purple.shade200,
    },
    {
      'name': 'Cardio',
      'image': 'assets/cardio.png',
      'color': Colors.teal.shade200,
    },
  ];

  // Currently selected category for showing exercises
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    _loadExercises();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _workoutNameController.dispose();
    _searchController.dispose();
    _notesController.dispose(); // Dispose the added controller
    super.dispose();
  }

  Future<void> _checkPremiumStatus() async {
    bool isPremium = await SubscriptionService.isPremium();
    setState(() {
      _isPremium = isPremium;
    });
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize empty lists for each muscle group
    for (var group in [..._bigThreeMuscleGroups, ..._boringMuscleGroups]) {
      _exercisesByCategory[group['name']] = [];
    }

    // Load all preset exercises
    final exercises = await DatabaseHelper.instance.getPresetExercises(
      _isPremium,
    );

    // Store all exercises in a flat list for searching
    _allExercises.addAll(exercises);

    // Organize exercises by category (muscle group)
    for (var exercise in exercises) {
      String category = exercise['category'] as String;
      // Map database categories to our simplified muscle groups
      String muscleGroup = _mapCategoryToMuscleGroup(category);

      if (_exercisesByCategory.containsKey(muscleGroup)) {
        _exercisesByCategory[muscleGroup]!.add(exercise);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    // Filter exercises based on search query
    final results =
        _allExercises.where((exercise) {
          final name = (exercise['name'] as String).toLowerCase();
          return name.contains(query);
        }).toList();

    setState(() {
      _isSearching = true;
      _searchResults = results;
    });
  }

  // Helper method to map detailed categories to main muscle groups
  String _mapCategoryToMuscleGroup(String category) {
    category = category.toLowerCase();
    if (category.contains('chest') || category.contains('pectoral')) {
      return 'Chest';
    } else if (category.contains('back') ||
        category.contains('lat') ||
        category.contains('trap')) {
      return 'Back';
    } else if (category.contains('leg') ||
        category.contains('quad') ||
        category.contains('hamstring') ||
        category.contains('calf') ||
        category.contains('glute')) {
      return 'Legs';
    } else if (category.contains('shoulder') || category.contains('delt')) {
      return 'Shoulders';
    } else if (category.contains('arm') ||
        category.contains('bicep') ||
        category.contains('tricep')) {
      return 'Arms';
    } else if (category.contains('cardio') ||
        category.contains('run') ||
        category.contains('bike') ||
        category.contains('sprint')) {
      return 'Cardio';
    } else {
      // Default to Arms if we can't categorize
      return 'Arms';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Workout')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Workout name input
                          TextFormField(
                            controller: _workoutNameController,
                            decoration: InputDecoration(
                              labelText: 'Workout Name',
                              hintText: 'e.g., Morning Chest Day',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a workout name';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 8),

                          // Notes field
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'Notes (optional)',
                              hintText:
                                  'Any additional notes about this workout',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),

                          SizedBox(height: 8),

                          // Search bar for exercises
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search Exercises',
                              hintText: 'e.g., Bench Press, Squats',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _isSearching = false;
                                            _searchResults = [];
                                          });
                                        },
                                      )
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // "Workouts Selection" header with custom styling
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Workouts Selection',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // Main content area - shows either search results, exercise list, or muscle groups
                    Expanded(
                      child:
                          _isSearching
                              ? _buildSearchResults()
                              : _selectedCategory == null
                              ? _buildMuscleGroupsGrid()
                              : _buildExerciseList(),
                    ),

                    // Bottom bar with selected exercises count
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.grey.shade200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected Exercises: ${_exercises.length}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            child: Text('SAVE WORKOUT'),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_exercises.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please add at least one exercise',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // Show a loading indicator while saving
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(width: 20),
                                            Text("Saving workout..."),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                try {
                                  // Save the workout
                                  await _saveWorkout();

                                  // Close the loading dialog
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }

                                  // Reset the form
                                  _workoutNameController.clear();
                                  _notesController.clear();
                                  setState(() {
                                    _exercises.clear();
                                  });

                                  // Show success message
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Workout saved! View it in the Progress tab under Exercises.',
                                        ),
                                        duration: Duration(seconds: 3),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // Close the loading dialog
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }

                                  // Show error message
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error saving workout: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No exercises found. Try a different search term.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final exercise = _searchResults[index];
        final isPremiumExercise = exercise['is_premium'] == 1;
        final muscleGroup = _mapCategoryToMuscleGroup(
          exercise['category'] as String,
        );
        final color = _getCategoryColor(muscleGroup);

        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(exercise['name'] as String),
            subtitle: Text(muscleGroup),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPremiumExercise)
                  Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      isPremiumExercise && !_isPremium
                          ? null
                          : () => _showExerciseDetailsDialog(exercise),
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                  child: Text('Add'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMuscleGroupsGrid() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big 3 Section
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Big 3',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children:
                _bigThreeMuscleGroups.map((group) {
                  return _buildMuscleGroupCard(group);
                }).toList(),
          ),

          SizedBox(height: 20),

          // Boring Section
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Boring',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children:
                _boringMuscleGroups.map((group) {
                  return _buildMuscleGroupCard(group);
                }).toList(),
          ),

          // Show selected exercises if any
          if (_exercises.isNotEmpty) ...[
            SizedBox(height: 20),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Selected Exercises',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ..._exercises.map(
              (exercise) => _buildSelectedExerciseTile(exercise),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMuscleGroupCard(Map<String, dynamic> group) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = group['name'];
        });
      },
      child: Card(
        color: group['color'],
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use Icon as placeholder, would be replaced with actual images
            Icon(
              _getIconForMuscleGroup(group['name']),
              size: 50,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            Text(
              group['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${_exercisesByCategory[group['name']]?.length ?? 0} exercises',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMuscleGroup(String muscleGroup) {
    switch (muscleGroup) {
      case 'Chest':
        return Icons.fitness_center;
      case 'Back':
        return Icons.sports_gymnastics;
      case 'Legs':
        return Icons.directions_walk;
      case 'Shoulders':
        return Icons.accessibility_new;
      case 'Arms':
        return Icons.sports_handball;
      case 'Cardio':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }

  Widget _buildExerciseList() {
    final exercises = _exercisesByCategory[_selectedCategory!] ?? [];

    return Column(
      children: [
        // Header with back button and category name
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: _getCategoryColor(_selectedCategory!),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              ),
              Icon(
                _getIconForMuscleGroup(_selectedCategory!),
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                _selectedCategory!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Exercise list
        Expanded(
          child:
              exercises.isEmpty
                  ? Center(
                    child: Text(
                      'No exercises available for $_selectedCategory',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      final isPremiumExercise = exercise['is_premium'] == 1;

                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(exercise['name'] as String),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPremiumExercise)
                                Icon(Icons.star, color: Colors.amber, size: 20),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed:
                                    isPremiumExercise && !_isPremium
                                        ? null
                                        : () => _showExerciseDetailsDialog(
                                          exercise,
                                        ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getCategoryColor(
                                    _selectedCategory!,
                                  ),
                                ),
                                child: Text('Add'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    final bigThreeGroup = _bigThreeMuscleGroups.firstWhere(
      (group) => group['name'] == category,
      orElse: () => {'color': null},
    );

    if (bigThreeGroup['color'] != null) {
      return bigThreeGroup['color'];
    }

    final boringGroup = _boringMuscleGroups.firstWhere(
      (group) => group['name'] == category,
      orElse: () => {'color': Colors.blue},
    );

    return boringGroup['color'];
  }

  Widget _buildSelectedExerciseTile(Map<String, dynamic> exercise) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(exercise['name']),
        subtitle: Text(
          '${exercise['sets']} sets × ${exercise['reps']} reps × ${exercise['weight']} kg',
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _exercises.removeWhere(
                (e) =>
                    e['name'] == exercise['name'] &&
                    e['sets'] == exercise['sets'] &&
                    e['reps'] == exercise['reps'] &&
                    e['weight'] == exercise['weight'],
              );
            });
          },
        ),
      ),
    );
  }

  void _showExerciseDetailsDialog(Map<String, dynamic> exercise) {
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final weightController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(exercise['name'] as String),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: setsController,
                decoration: InputDecoration(
                  labelText: 'Sets',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              TextField(
                controller: repsController,
                decoration: InputDecoration(
                  labelText: 'Reps',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('ADD'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _selectedCategory != null
                        ? _getCategoryColor(_selectedCategory!)
                        : null,
              ),
              onPressed: () {
                final newExercise = {
                  'name': exercise['name'],
                  'sets': int.tryParse(setsController.text) ?? 3,
                  'reps': int.tryParse(repsController.text) ?? 10,
                  'weight': double.tryParse(weightController.text) ?? 0.0,
                };

                setState(() {
                  _exercises.add(newExercise);
                });

                // Close the dialog but keep the workout intact
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _saveWorkout() async {
    // Show a loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate input again (double-check)
      if (_workoutNameController.text.isEmpty) {
        throw Exception('Workout name cannot be empty');
      }

      if (_exercises.isEmpty) {
        throw Exception('Please add at least one exercise');
      }

      // Create workout record with current timestamp
      final workout = {
        'name': _workoutNameController.text.trim(),
        'date': DateTime.now().toIso8601String(),
        'notes': _notesController.text.trim(),
      };

      // Insert workout and get ID
      final workoutId = await DatabaseHelper.instance.insertWorkout(workout);

      // Insert all exercises
      for (var exercise in _exercises) {
        final exerciseRecord = {
          'workout_id': workoutId,
          'name': exercise['name'],
          'sets': exercise['sets'],
          'reps': exercise['reps'],
          'weight': exercise['weight'],
        };

        await DatabaseHelper.instance.insertExercise(exerciseRecord);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      return true;
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving workout: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      // Hide loading indicator
      setState(() {
        _isLoading = false;
      });
    }
  }
}
// delete this line 