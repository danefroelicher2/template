// lib/screens/progress_page.dart - Modified to display saved workouts
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import '../services/subscription_service.dart';
import 'premium_page.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  bool _isPremium = false;
  bool _isLoading = true;
  late TabController _tabController;

  // Sample data structures for progress tracking
  List<Map<String, dynamic>> _recentWorkouts = [];
  List<Map<String, dynamic>> _savedExercises = [];
  Map<String, List<Map<String, dynamic>>> _exerciseProgress = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkPremiumStatus();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when the page is revisited (e.g., after adding a new workout)
    _loadData();
  }

  Future<void> _checkPremiumStatus() async {
    final isPremium = await SubscriptionService.isPremium();
    setState(() {
      _isPremium = isPremium;
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load recent workouts (last 10)
    final workouts = await DatabaseHelper.instance.getRecentWorkouts(10);

    // Load exercise progress data
    // This would track a user's performance for specific exercises over time
    final exercises = await DatabaseHelper.instance.getAllExercises();

    // Group exercises by name to show progress
    final Map<String, List<Map<String, dynamic>>> exerciseProgress = {};
    for (var exercise in exercises) {
      final name = exercise['name'] as String;
      if (!exerciseProgress.containsKey(name)) {
        exerciseProgress[name] = [];
      }
      exerciseProgress[name]!.add(exercise);
    }

    // Sort each exercise list by date
    exerciseProgress.forEach((name, exerciseList) {
      exerciseList.sort((a, b) {
        final aWorkoutId = a['workout_id'] as int;
        final bWorkoutId = b['workout_id'] as int;
        return bWorkoutId.compareTo(aWorkoutId); // Descending order
      });
    });

    setState(() {
      _recentWorkouts = workouts;
      _savedExercises = exercises;
      _exerciseProgress = exerciseProgress;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Summary'),
            Tab(text: 'Exercises'),
            Tab(text: 'Body Stats'),
          ],
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildSummaryTab(),
                  _buildExercisesTab(),
                  _buildBodyStatsTab(),
                ],
              ),
    );
  }

  Widget _buildSummaryTab() {
    // Check if we have enough data to show progress
    final bool hasWorkoutData = _recentWorkouts.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout streak card
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Streak',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.local_fire_department, color: Colors.orange),
                    ],
                  ),
                  SizedBox(height: 16),
                  hasWorkoutData
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('3', 'Days'),
                          _buildStatColumn(
                            '${_recentWorkouts.length}',
                            'Workouts',
                          ),
                          _buildStatColumn(
                            '${_savedExercises.length}',
                            'Exercises',
                          ),
                        ],
                      )
                      : Center(
                        child: Text(
                          'Complete your first workout to start tracking progress!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Recent achievements
          Text(
            'Recent Achievements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          hasWorkoutData
              ? _buildAchievementsList()
              : Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Complete workouts to earn achievements',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),

          SizedBox(height: 16),

          // Weekly activity chart
          Text(
            'Weekly Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child:
                  hasWorkoutData
                      ? SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            _isPremium
                                ? 'Weekly activity chart would appear here'
                                : 'Upgrade to Pro for detailed activity charts',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : Center(
                        child: Text(
                          'Complete workouts to view your activity',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
            ),
          ),

          // Premium upgrade prompt (if not premium)
          if (!_isPremium)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Upgrade to Pro for advanced progress tracking',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PremiumPage(),
                            ),
                          );
                          _checkPremiumStatus();
                        },
                        child: Text('UPGRADE TO PRO'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExercisesTab() {
    // Get unique exercise names
    final exerciseNames = _exerciseProgress.keys.toList()..sort();

    if (exerciseNames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No exercise data yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Complete workouts to see your progress',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Add New Workout'),
              onPressed: () {
                // Navigate to new workout page
                Navigator.pushNamed(context, '/new_workout').then((_) {
                  // Refresh data when returning
                  _loadData();
                });
              },
            ),
          ],
        ),
      );
    }

    // Group exercises by workout for better organization
    Map<int, List<Map<String, dynamic>>> exercisesByWorkout = {};
    Map<int, Map<String, dynamic>> workoutDetails = {};

    // Process all exercises to group them by workout
    for (var exercise in _savedExercises) {
      final workoutId = exercise['workout_id'] as int;

      if (!exercisesByWorkout.containsKey(workoutId)) {
        exercisesByWorkout[workoutId] = [];

        // Find the workout details
        for (var workout in _recentWorkouts) {
          if (workout['id'] == workoutId) {
            workoutDetails[workoutId] = workout;
            break;
          }
        }
      }

      exercisesByWorkout[workoutId]!.add(exercise);
    }

    // Sort workouts by date (newest first)
    final workoutIds =
        workoutDetails.keys.toList()..sort((a, b) {
          final dateA = workoutDetails[a]?['date'] as String? ?? '';
          final dateB = workoutDetails[b]?['date'] as String? ?? '';
          return dateB.compareTo(dateA); // Descending
        });

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Your Workout History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily:
                  'Pacifico', // Matching the cursive font from NewWorkoutPage
            ),
          ),
          SizedBox(height: 16),

          // Workouts expandable list
          ...workoutIds.map((workoutId) {
            final workout = workoutDetails[workoutId];
            final exercises = exercisesByWorkout[workoutId] ?? [];
            final date = DateTime.parse(
              workout?['date'] as String? ?? DateTime.now().toIso8601String(),
            );

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ExpansionTile(
                title: Text(
                  workout?['name'] as String? ?? 'Workout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${date.day}/${date.month}/${date.year} • ${exercises.length} exercises',
                  style: TextStyle(fontSize: 12),
                ),
                children: [
                  ...exercises.map(
                    (exercise) => ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      title: Text(exercise['name'] as String),
                      subtitle: Text(
                        '${exercise['sets']} sets × ${exercise['reps']} reps × ${exercise['weight']} kg',
                      ),
                      trailing: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: () {
                        // Show progress chart for this exercise if premium
                        if (_isPremium) {
                          // Would show detailed chart
                          _showExerciseProgressChart(
                            exercise['name'] as String,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Upgrade to Pro for detailed exercise analytics',
                              ),
                              action: SnackBarAction(
                                label: 'UPGRADE',
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PremiumPage(),
                                    ),
                                  );
                                  _checkPremiumStatus();
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          SizedBox(height: 16),

          // Add new workout button
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Add New Workout'),
              onPressed: () {
                // Navigate to new workout page
                Navigator.pushNamed(context, '/new_workout').then((_) {
                  // Refresh data when returning
                  _loadData();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showExerciseProgressChart(String exerciseName) {
    // Get all instances of this exercise from the progress data
    final exerciseInstances = _exerciseProgress[exerciseName] ?? [];

    if (exerciseInstances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No progress data available for $exerciseName')),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Progress: $exerciseName'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: DatabaseHelper.instance.getExerciseProgressData(
                        exerciseName,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final data = snapshot.data!;
                        if (data.isEmpty) {
                          return Center(child: Text('No data available'));
                        }

                        // Prepare data for the chart
                        List<FlSpot> weightSpots = [];
                        for (int i = 0; i < data.length; i++) {
                          final entry = data[i];
                          weightSpots.add(
                            FlSpot(i.toDouble(), entry['weight'] as double),
                          );
                        }

                        return LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < data.length) {
                                      final date = DateTime.parse(
                                        data[value.toInt()]['date'] as String,
                                      );
                                      return Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '${date.day}/${date.month}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: weightSpots,
                                isCurved: true,
                                color: Theme.of(context).primaryColor,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Weight Progression (kg)',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('CLOSE'),
              ),
            ],
          ),
    );
  }

  Widget _buildBodyStatsTab() {
    // This tab would allow users to track body measurements
    // Such as weight, body fat percentage, measurements, etc.

    // For MVP, we'll just show a placeholder with upgrade prompt for non-premium
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Body Stats Tracking',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _isPremium
                  ? 'Track your weight, body fat percentage, and other measurements over time.'
                  : 'Upgrade to Pro to track your body stats and see your progress over time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            if (!_isPremium)
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PremiumPage()),
                  );
                  _checkPremiumStatus();
                },
                child: Text('UPGRADE TO PRO'),
              )
            else
              Text(
                'Body stats tracking feature coming soon!',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildAchievementsList() {
    // Sample achievements based on actual workout data
    List<Map<String, dynamic>> achievements = [];

    // Add first workout achievement if we have workouts
    if (_recentWorkouts.isNotEmpty) {
      final firstWorkout =
          _recentWorkouts.last; // Last in the list is the earliest
      final date = DateTime.parse(firstWorkout['date'] as String);

      achievements.add({
        'title': 'First Workout',
        'date': '${date.day}/${date.month}/${date.year}',
        'icon': Icons.fitness_center,
      });
    }

    // Add milestone achievements based on workout count
    if (_recentWorkouts.length >= 5) {
      achievements.add({
        'title': '5 Workouts Completed',
        'date': 'Recently',
        'icon': Icons.repeat,
      });
    }

    // Add weight milestone if applicable
    double maxWeight = 0;
    String exerciseWithMaxWeight = '';

    for (var exercise in _savedExercises) {
      if ((exercise['weight'] as double) > maxWeight) {
        maxWeight = exercise['weight'] as double;
        exerciseWithMaxWeight = exercise['name'] as String;
      }
    }

    if (maxWeight > 50) {
      // Arbitrary threshold
      achievements.add({
        'title': 'Weight Milestone: ${maxWeight}kg ${exerciseWithMaxWeight}',
        'date': 'Recently',
        'icon': Icons.trending_up,
      });
    }

    // If no real achievements yet, add a placeholder
    if (achievements.isEmpty) {
      achievements.add({
        'title': 'Starting Your Fitness Journey',
        'date': 'Today',
        'icon': Icons.emoji_events,
      });
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: achievements.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                achievement['icon'] as IconData,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(achievement['title'] as String),
            subtitle: Text(achievement['date'] as String),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
