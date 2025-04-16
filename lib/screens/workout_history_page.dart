// lib/screens/workout_history_page.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class WorkoutHistoryPage extends StatefulWidget {
  const WorkoutHistoryPage({super.key});

  @override
  _WorkoutHistoryPageState createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  List<Map<String, dynamic>> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
    });

    final workouts = await DatabaseHelper.instance.getWorkouts();

    setState(() {
      _workouts = workouts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Workout History')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _workouts.isEmpty
              ? Center(
                child: Text(
                  'No workouts yet.\nStart by creating a new workout!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: _workouts.length,
                itemBuilder: (context, index) {
                  final workout = _workouts[index];
                  final date = DateTime.parse(workout['date'] as String);

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      title: Text(workout['name'] as String),
                      subtitle: Text(
                        '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                      ),
                      children: [
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: DatabaseHelper.instance
                              .getExercisesForWorkout(workout['id'] as int),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            final exercises = snapshot.data!;
                            return Column(
                              children: [
                                if (workout['notes'] != null &&
                                    (workout['notes'] as String).isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notes: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            workout['notes'] as String,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: exercises.length,
                                  itemBuilder: (context, index) {
                                    final exercise = exercises[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(exercise['name'] as String),
                                      subtitle: Text(
                                        '${exercise['sets']} sets × ${exercise['reps']} reps × ${exercise['weight']} kg',
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
