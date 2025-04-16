// lib/widgets/workout_progress_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';

class WorkoutProgressChart extends StatefulWidget {
  final String exerciseName;

  const WorkoutProgressChart({super.key, required this.exerciseName});

  @override
  _WorkoutProgressChartState createState() => _WorkoutProgressChartState();
}

class _WorkoutProgressChartState extends State<WorkoutProgressChart> {
  List<Map<String, dynamic>> _exerciseData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExerciseData();
  }

  Future<void> _loadExerciseData() async {
    setState(() {
      _isLoading = true;
    });

    // Get exercise data for the specified exercise
    final data = await DatabaseHelper.instance.getExerciseProgressData(
      widget.exerciseName,
    );

    setState(() {
      _exerciseData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_exerciseData.isEmpty) {
      return Center(
        child: Text(
          'No data available for ${widget.exerciseName}',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Prepare data for the chart
    List<FlSpot> weightSpots = [];

    for (int i = 0; i < _exerciseData.length; i++) {
      final entry = _exerciseData[i];
      weightSpots.add(FlSpot(i.toDouble(), entry['weight'] as double));
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.exerciseName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Weight Progression (kg)',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _exerciseData.length) {
                          final date = DateTime.parse(
                            _exerciseData[value.toInt()]['date'] as String,
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
            ),
          ),
        ],
      ),
    );
  }
}
