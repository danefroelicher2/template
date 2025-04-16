// lib/screens/exercise_library_page.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/subscription_service.dart';
import 'premium_page.dart';

class ExerciseLibraryPage extends StatefulWidget {
  const ExerciseLibraryPage({super.key});

  @override
  _ExerciseLibraryPageState createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  bool _isPremium = false;
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _isLoading = true;
    });

    final isPremium = await SubscriptionService.isPremium();

    // Load all exercises
    final exercises = await DatabaseHelper.instance.getPresetExercises(
      isPremium,
    );

    // Extract unique categories
    final categoriesSet = <String>{};
    for (var exercise in exercises) {
      categoriesSet.add(exercise['category'] as String);
    }

    setState(() {
      _isPremium = isPremium;
      _categories = categoriesSet.toList()..sort();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise Library')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  if (!_isPremium)
                    Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.amber.shade100,
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Upgrade to Pro to unlock all premium exercises!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            child: Text('UPGRADE'),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PremiumPage(),
                                ),
                              );
                              _init(); // Refresh after returning
                            },
                          ),
                        ],
                      ),
                    ),

                  // Category selector
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Muscle Group',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),

                  // Exercise list
                  Expanded(
                    child:
                        _selectedCategory == null
                            ? Center(child: Text('Select a muscle group'))
                            : FutureBuilder<List<Map<String, dynamic>>>(
                              future: DatabaseHelper.instance
                                  .getPresetExercisesByCategory(
                                    _selectedCategory!,
                                    _isPremium,
                                  ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final exercises = snapshot.data!;
                                return ListView.builder(
                                  itemCount: exercises.length,
                                  itemBuilder: (context, index) {
                                    final exercise = exercises[index];
                                    final isPremiumExercise =
                                        exercise['is_premium'] == 1;

                                    return ListTile(
                                      title: Text(exercise['name'] as String),
                                      trailing:
                                          isPremiumExercise
                                              ? Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              )
                                              : null,
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
