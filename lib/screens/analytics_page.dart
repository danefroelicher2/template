// lib/screens/analytics_page.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/subscription_service.dart';
import '../widgets/workout_progress_chart.dart';
import 'premium_page.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _isPremium = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _workouts = [];
  List<String> _topExercises = [];

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    setState(() {
      _isLoading = true;
    });

    final isPremium = await SubscriptionService.isPremium();

    if (isPremium) {
      // Load data only if premium
      final workouts = await DatabaseHelper.instance.getWorkouts();
      final topExercises = await DatabaseHelper.instance.getTopExercises(5);

      setState(() {
        _isPremium = isPremium;
        _workouts = workouts;
        _topExercises = topExercises;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isPremium = isPremium;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Analytics')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isPremium) {
      // Redirect to premium page if not premium
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PremiumPage()),
        );
      });
      return Container();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Analytics')),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_workouts.isEmpty) {
      return Center(
        child: Text(
          'No workout data yet.\nStart by creating some workouts!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkoutSummary(),
          SizedBox(height: 24),

          Text(
            'Your Progress',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          if (_topExercises.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No exercise data yet.\nTrack your workouts to see progress!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._topExercises.map(
              (exercise) => Card(
                margin: EdgeInsets.only(bottom: 16),
                child: WorkoutProgressChart(exerciseName: exercise),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildStatTile('Total Workouts', '${_workouts.length}'),
            _buildStatTile('This Week', '${_countWorkoutsThisWeek(_workouts)}'),
            _buildStatTile('Most Common', _getMostCommonWorkout(_workouts)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  int _countWorkoutsThisWeek(List<Map<String, dynamic>> workouts) {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    return workouts.where((workout) {
      final workoutDate = DateTime.parse(workout['date'] as String);
      return workoutDate.isAfter(startOfWeek);
    }).length;
  }

  String _getMostCommonWorkout(List<Map<String, dynamic>> workouts) {
    if (workouts.isEmpty) return 'None';

    // Count workout names
    final Map<String, int> counts = {};
    for (var workout in workouts) {
      final name = workout['name'] as String;
      counts[name] = (counts[name] ?? 0) + 1;
    }

    // Find the most common
    String mostCommon = workouts.first['name'] as String;
    int highestCount = 0;

    counts.forEach((name, count) {
      if (count > highestCount) {
        highestCount = count;
        mostCommon = name;
      }
    });

    return mostCommon;
  }
}
