// lib/screens/main_navigation.dart
import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import 'home_page.dart';
import 'new_workout_page.dart';
import 'progress_page.dart'; // Import the new progress page
import 'profile_page.dart'; // Import the new profile page

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _isPremium = false;

  // Controllers for each tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens with new tab structure
    _screens = [
      HomePage(navigateToWorkout: () => _onTabTapped(1)),
      NewWorkoutPage(),
      ProgressPage(), // New Progress tab
      ProfilePage(), // New Profile tab
    ];

    // Check premium status after initialization
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    bool isPremium = await SubscriptionService.isPremium();
    setState(() {
      _isPremium = isPremium;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define a consistent color for all tabs
    final Color tabColor = Colors.grey[800]!;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Theme(
        // Override the NavigationBar theme to ensure consistent colors
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: tabColor,
            unselectedItemColor: tabColor,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          // Make all tabs the same color regardless of selection
          selectedItemColor: tabColor,
          unselectedItemColor: tabColor,
          // Use these to indicate the active tab without changing color
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          showUnselectedLabels: true,
          items: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.fitness_center, 'Workout', 1),
            _buildNavItem(
              Icons.trending_up,
              'Progress',
              2,
            ), // Changed icon and label
            _buildNavItem(Icons.person, 'Profile', 3), // Changed icon and label
          ],
        ),
      ),
    );
  }

  // Helper method to build navigation items with consistent styling
  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    final bool isSelected = _currentIndex == index;

    // Create a container with decoration to indicate selection
    Widget iconWidget = Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border:
            isSelected
                ? Border(
                  bottom: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 3.0,
                  ),
                )
                : null,
      ),
      child: Icon(icon),
    );

    return BottomNavigationBarItem(icon: iconWidget, label: label);
  }
}
