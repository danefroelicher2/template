// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import 'premium_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final Function? navigateToWorkout;

  const HomePage({super.key, this.navigateToWorkout});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    bool isPremium = await SubscriptionService.isPremium();
    setState(() {
      _isPremium = isPremium;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GymTracker ${_isPremium ? "Pro" : "Free"}'),
        actions: [
          // Gold crown for premium upgrade
          if (!_isPremium)
            IconButton(
              icon: Icon(Icons.star, color: Colors.amber[600]),
              tooltip: 'Upgrade to Pro',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PremiumPage()),
                );
                _checkPremiumStatus();
              },
            ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              ).then((_) => _checkPremiumStatus());
            },
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Theme.of(context).primaryColor],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Welcome to GymTracker',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your personal fitness journey starts here',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // App features section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track Your Progress',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  _buildFeatureItem(
                    context,
                    icon: Icons.fitness_center,
                    title: 'Log Workouts',
                    description:
                        'Easily track your sets, reps, and weights for each exercise.',
                  ),

                  _buildFeatureItem(
                    context,
                    icon: Icons.history,
                    title: 'Workout History',
                    description:
                        'Review past workouts to see how far you\'ve come.',
                  ),

                  _buildFeatureItem(
                    context,
                    icon: Icons.menu_book,
                    title: 'Exercise Library',
                    description:
                        'Browse hundreds of exercises with detailed instructions.',
                  ),

                  _buildFeatureItem(
                    context,
                    icon: Icons.analytics,
                    title: 'Advanced Analytics',
                    description:
                        _isPremium
                            ? 'Get insights into your performance and progress.'
                            : 'Upgrade to Pro to unlock detailed performance analytics.',
                  ),
                ],
              ),
            ),

            // Quick Start section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Started Now',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      // Use callback if provided, otherwise navigate the old way
                      if (widget.navigateToWorkout != null) {
                        widget.navigateToWorkout!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fitness_center),
                        SizedBox(width: 8),
                        Text('Start a Workout', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Health tips section
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Fitness Tip',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Remember to stay hydrated during your workouts! Aim to drink at least 16-20 oz of water an hour before exercise, 8 oz every 15 minutes during exercise, and 16-24 oz after your workout.',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),

            // Spacer to ensure bottom content isn't hidden behind nav bar
            SizedBox(height: 60),
          ],
        ),
      ),
      // Removed the bottom navigation bar since it's now in MainNavigation
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
