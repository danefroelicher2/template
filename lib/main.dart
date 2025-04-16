// lib/main.dart - Updated for onboarding experience
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'database/database_helper.dart';
import 'providers/auth_provider.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart'; // Import the theme configuration
import 'screens/onboarding/onboarding_page.dart';
import 'wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  try {
    // Try to initialize the database for offline support
    if (!kIsWeb) {
      await DatabaseHelper.instance.database;
    }
  } catch (e) {
    print("Database initialization error: $e");
  }

  // Initialize theme service
  await ThemeService.instance.init();

  runApp(GymTrackerApp());
}

class GymTrackerApp extends StatefulWidget {
  const GymTrackerApp({super.key});

  @override
  _GymTrackerAppState createState() => _GymTrackerAppState();
}

class _GymTrackerAppState extends State<GymTrackerApp> {
  @override
  void initState() {
    super.initState();
    ThemeService.instance.themeMode.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService.instance.themeMode.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers as needed
      ],
      child: MaterialApp(
        title: 'GymTracker Pro',
        debugShowCheckedModeBanner: false,
        // Use our custom theme configurations
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeService.instance.currentThemeMode,
        home: AppInitializer(),
      ),
    );
  }
}

// App initializer that checks for onboarding status
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<bool> _onboardingCheckFuture;

  @override
  void initState() {
    super.initState();
    _onboardingCheckFuture = _checkIfOnboardingCompleted();
  }

  // Check if onboarding has been completed
  Future<bool> _checkIfOnboardingCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _onboardingCheckFuture,
      builder: (context, snapshot) {
        // While checking, show loading with a themed splash screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSplashScreen(context);
        }

        // If onboarding completed, go to auth flow, otherwise show onboarding
        final bool onboardingCompleted = snapshot.data ?? false;
        if (onboardingCompleted) {
          return AuthInitializer();
        } else {
          return OnboardingPage();
        }
      },
    );
  }

  // Build a more polished splash screen
  Widget _buildSplashScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 24),

              // App name
              Text(
                'GymTracker Pro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48),

              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The existing auth initializer is still used after onboarding
class AuthInitializer extends StatefulWidget {
  const AuthInitializer({super.key});

  @override
  _AuthInitializerState createState() => _AuthInitializerState();
}

class _AuthInitializerState extends State<AuthInitializer> {
  late Future<void> _initializationFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize in didChangeDependencies which is safe to use with Provider
    _initializationFuture =
        Provider.of<AuthProvider>(context, listen: false).initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(context);
        }
        return Wrapper();
      },
    );
  }

  // Loading screen during auth initialization
  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Loading your profile...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
