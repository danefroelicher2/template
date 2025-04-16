// lib/screens/add_exercise_page.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddExercisePage extends StatefulWidget {
  final bool isPremium;

  const AddExercisePage({super.key, required this.isPremium});

  @override
  _AddExercisePageState createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseNameController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _weightController = TextEditingController(text: '0');

  List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadPresetExercises();
  }

  Future<void> _loadPresetExercises() async {
    // Load all preset exercises
    final exercises = await DatabaseHelper.instance.getPresetExercises(
      widget.isPremium,
    );

    // Extract unique categories
    final categoriesSet = <String>{};
    for (var exercise in exercises) {
      categoriesSet.add(exercise['category'] as String);
    }

    setState(() {
      _categories = categoriesSet.toList()..sort();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Exercise')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextFormField(
                controller: _exerciseNameController,
                decoration: InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'e.g., Bench Press',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.list),
                    tooltip: 'Select from preset exercises',
                    onPressed: () {
                      _showPresetExercisesDialog();
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an exercise name';
                  }
                  return null;
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _setsController,
                      decoration: InputDecoration(
                        labelText: 'Sets',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      decoration: InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(child: Container()),

            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('ADD TO WORKOUT', style: TextStyle(fontSize: 16)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final exercise = {
                      'name': _exerciseNameController.text,
                      'sets': int.parse(_setsController.text),
                      'reps': int.parse(_repsController.text),
                      'weight': double.parse(_weightController.text),
                    };

                    Navigator.pop(context, exercise);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPresetExercisesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Exercise'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: Text('Select Category'),
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
                  SizedBox(height: 8),
                  SizedBox(
                    height: 300,
                    width: double.maxFinite,
                    child:
                        _selectedCategory == null
                            ? Center(child: Text('Select a category'))
                            : FutureBuilder<List<Map<String, dynamic>>>(
                              future: DatabaseHelper.instance
                                  .getPresetExercisesByCategory(
                                    _selectedCategory!,
                                    widget.isPremium,
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
                                    final isPremium =
                                        exercise['is_premium'] == 1;

                                    return ListTile(
                                      title: Text(exercise['name'] as String),
                                      trailing:
                                          isPremium
                                              ? Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              )
                                              : null,
                                      enabled: !isPremium || widget.isPremium,
                                      onTap: () {
                                        _exerciseNameController.text =
                                            exercise['name'] as String;
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('CANCEL'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
