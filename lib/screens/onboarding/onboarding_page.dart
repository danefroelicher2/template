// lib/screens/onboarding/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/welcome_screen.dart';
import '../../services/theme_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  // Personalization data
  String _fitnessGoal = 'Strength';
  int _experienceLevel = 1; // 1-3: Beginner, Intermediate, Advanced
  List<bool> _workoutDays = List.filled(7, false); // Sun to Sat
  int _workoutsPerWeek = 3;
  String _focusArea = 'Full Body';

  // Theme preference
  bool _useDarkMode = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == 1; // We have 2 slides (0-indexed)
    });
  }

  void _goToNextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // Save that onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    // Save personalization data locally
    await prefs.setString('fitness_goal', _fitnessGoal);
    await prefs.setInt('experience_level', _experienceLevel);
    await prefs.setStringList(
      'workout_days',
      _workoutDays
          .asMap()
          .entries
          .where((entry) => entry.value)
          .map((entry) => entry.key.toString())
          .toList(),
    );
    await prefs.setInt('workouts_per_week', _workoutsPerWeek);
    await prefs.setString('focus_area', _focusArea);

    // Set theme mode based on user preference
    await ThemeService.instance.setThemeMode(
      _useDarkMode ? ThemeMode.dark : ThemeMode.light,
    );

    // Navigate to welcome screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => WelcomeScreen(
              fitnessGoal: _fitnessGoal,
              experienceLevel: _experienceLevel,
              workoutDays: _workoutDays,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _useDarkMode
              ? Color(0xFF121212) // Dark background
              : Colors.white, // Light background
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    _isLastPage ? 'FINISH' : 'SKIP',
                    style: TextStyle(
                      color: _useDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildPersonalizationSlide(),
                  _buildThemeSelectionSlide(),
                ],
              ),
            ),

            // Navigation controls
            Container(
              padding: EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots indicator
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == 0
                                  ? Theme.of(context).primaryColor
                                  : (_useDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[300]),
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == 1
                                  ? Theme.of(context).primaryColor
                                  : (_useDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[300]),
                        ),
                      ),
                    ],
                  ),

                  // Next button
                  ElevatedButton(
                    onPressed: _goToNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(_isLastPage ? 'GET STARTED' : 'NEXT'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // First slide - Personalization
  Widget _buildPersonalizationSlide() {
    // Lists for dropdowns
    final List<String> fitnessGoals = [
      'Strength',
      'Muscle Gain',
      'Weight Loss',
      'Endurance',
      'General Fitness',
    ];

    final List<String> focusAreas = [
      'Full Body',
      'Upper Body',
      'Lower Body',
      'Core',
      'Cardio',
    ];

    final List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    final List<String> experienceLevels = [
      'Beginner',
      'Intermediate',
      'Advanced',
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Icon(
                Icons.fitness_center,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24),

            Center(
              child: Text(
                'Personalize Your Experience',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _useDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),

            // Fitness goal
            Text(
              'What is your primary fitness goal?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _useDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _useDarkMode ? Color(0xFF2A2A2A) : Colors.grey[100],
              ),
              child: DropdownButtonFormField<String>(
                value: _fitnessGoal,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                dropdownColor: _useDarkMode ? Color(0xFF2A2A2A) : Colors.white,
                style: TextStyle(
                  color: _useDarkMode ? Colors.white : Colors.black87,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: _useDarkMode ? Colors.white70 : Colors.black54,
                ),
                items:
                    fitnessGoals.map((goal) {
                      return DropdownMenuItem<String>(
                        value: goal,
                        child: Text(goal),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _fitnessGoal = value;
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 20),

            // Focus area
            Text(
              'What area would you like to focus on?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _useDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _useDarkMode ? Color(0xFF2A2A2A) : Colors.grey[100],
              ),
              child: DropdownButtonFormField<String>(
                value: _focusArea,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                dropdownColor: _useDarkMode ? Color(0xFF2A2A2A) : Colors.white,
                style: TextStyle(
                  color: _useDarkMode ? Colors.white : Colors.black87,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: _useDarkMode ? Colors.white70 : Colors.black54,
                ),
                items:
                    focusAreas.map((area) {
                      return DropdownMenuItem<String>(
                        value: area,
                        child: Text(area),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _focusArea = value;
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 20),

            // Experience level
            Text(
              'What is your fitness experience level?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _useDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _experienceLevel = index + 1;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color:
                          _experienceLevel == index + 1
                              ? Theme.of(context).primaryColor
                              : (_useDarkMode
                                  ? Color(0xFF2A2A2A)
                                  : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          index == 0
                              ? Icons.fitness_center
                              : index == 1
                              ? Icons.directions_run
                              : Icons.sports_gymnastics,
                          color:
                              _experienceLevel == index + 1
                                  ? Colors.white
                                  : (_useDarkMode
                                      ? Colors.white70
                                      : Colors.black54),
                        ),
                        SizedBox(height: 8),
                        Text(
                          experienceLevels[index],
                          style: TextStyle(
                            color:
                                _experienceLevel == index + 1
                                    ? Colors.white
                                    : (_useDarkMode
                                        ? Colors.white70
                                        : Colors.black54),
                            fontWeight:
                                _experienceLevel == index + 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),

            // Workouts per week
            Text(
              'How many times per week do you want to work out?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _useDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1',
                  style: TextStyle(
                    color: _useDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  '7',
                  style: TextStyle(
                    color: _useDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor:
                    _useDarkMode ? Colors.grey[700] : Colors.grey[300],
                thumbColor: Theme.of(context).primaryColor,
                valueIndicatorColor: Theme.of(context).primaryColor,
                valueIndicatorTextStyle: TextStyle(color: Colors.white),
                showValueIndicator: ShowValueIndicator.always,
              ),
              child: Slider(
                min: 1,
                max: 7,
                divisions: 6,
                value: _workoutsPerWeek.toDouble(),
                label: '$_workoutsPerWeek',
                onChanged: (value) {
                  setState(() {
                    _workoutsPerWeek = value.toInt();
                  });
                },
              ),
            ),
            SizedBox(height: 20),

            // Workout days
            Text(
              'Which days do you plan to work out?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _useDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(weekdays.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _workoutDays[index] = !_workoutDays[index];
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _workoutDays[index]
                              ? Theme.of(context).primaryColor
                              : (_useDarkMode
                                  ? Color(0xFF2A2A2A)
                                  : Colors.grey[100]),
                    ),
                    child: Center(
                      child: Text(
                        weekdays[index],
                        style: TextStyle(
                          color:
                              _workoutDays[index]
                                  ? Colors.white
                                  : (_useDarkMode
                                      ? Colors.white70
                                      : Colors.black54),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Second slide - Theme selection
  Widget _buildThemeSelectionSlide() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose Your Theme',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _useDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),

          Row(
            children: [
              // Light mode option
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _useDarkMode = false;
                    });
                  },
                  child: Container(
                    height: 320,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      border:
                          !_useDarkMode
                              ? Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 3,
                              )
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.light_mode, size: 50, color: Colors.amber),
                        SizedBox(height: 16),
                        Text(
                          'Light Mode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 24),
                        // Mock UI
                        Container(
                          width: 120,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 16,
                                color: Colors.blue,
                                margin: EdgeInsets.symmetric(vertical: 6),
                              ),
                              Container(
                                width: 100,
                                height: 10,
                                color: Colors.grey[400],
                                margin: EdgeInsets.symmetric(vertical: 4),
                              ),
                              Container(
                                width: 100,
                                height: 10,
                                color: Colors.grey[400],
                                margin: EdgeInsets.symmetric(vertical: 4),
                              ),
                              Container(
                                width: 100,
                                height: 10,
                                color: Colors.grey[400],
                                margin: EdgeInsets.symmetric(vertical: 4),
                              ),
                              SizedBox(height: 16),
                              Container(
                                width: 80,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Dark mode option
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _useDarkMode = true;
                    });
                  },
                  child: Container(
                    height: 320,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF121212),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      border:
                          _useDarkMode
                              ? Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 3,
                              )
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dark_mode,
                          size: 50,
                          color: Colors.indigo[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 24),
                        // Mock UI
                        Container(
                          width: 120,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 16,
                                color: Colors.blue[700],
                                margin: EdgeInsets.symmetric(vertical: 6),
                              ),
                              Container(
                                width: 100,
                                height: 10,
                                color: Colors.grey[600],
                                margin: EdgeInsets.symmetric(vertical: 4),
                              ),
                              Container(
                                width: 100,
                                height: 10,
                                color: Colors.grey[600],
                                margin: EdgeInsets.symmetric(vertical: 4),
                              ),
                              Container(
                                width: 100,
                                height: 10,
                                color: Colors.grey[600],
                                margin: EdgeInsets.symmetric(vertical: 4),
                              ),
                              SizedBox(height: 16),
                              Container(
                                width: 80,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.blue[700],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),

          Text(
            'You can always change this later in Settings',
            style: TextStyle(
              fontSize: 14,
              color: _useDarkMode ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
