// lib/screens/settings_page.dart - Enhanced with theme toggle and debug options
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/subscription_service.dart';
import '../services/theme_service.dart';
import '../widgets/theme_toggle.dart'; // Import our new theme toggle widget
import 'premium_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  bool _isPremium = false;
  late ThemeMode _currentThemeMode;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    _currentThemeMode = ThemeService.instance.currentThemeMode;

    // Animation controller for theme change effects
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkPremiumStatus() async {
    final isPremium = await SubscriptionService.isPremium();
    setState(() {
      _isPremium = isPremium;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings'), elevation: 0),
      body: AnimatedBuilder(
        animation: ThemeService.instance.themeMode,
        builder: (context, _) {
          return ListView(
            children: [
              // App appearance section
              _buildSectionHeader('App Appearance'),

              // Theme toggle
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Theme mode selector
                      ListTile(
                        title: Text('App Theme'),
                        subtitle: Text(_getThemeText()),
                        leading: Icon(
                          ThemeService.instance.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                        trailing: ThemeToggle(showLabel: false),
                        onTap: _showThemeSelectionDialog,
                      ),
                    ],
                  ),
                ),
              ),

              // Subscriptions and account section
              _buildSectionHeader('Account & Subscription'),

              // Subscription tile
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Subscription'),
                  subtitle: Text(_isPremium ? 'Pro' : 'Free'),
                  leading: Icon(Icons.star),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PremiumPage()),
                    ).then((_) => _checkPremiumStatus());
                  },
                ),
              ),

              // Units and preferences section
              _buildSectionHeader('Preferences'),

              // Units selection
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Units'),
                  subtitle: Text('Kilograms (kg)'),
                  leading: Icon(Icons.scale),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Would open unit selection dialog in a real app
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Unit settings would open here')),
                    );
                  },
                ),
              ),

              // Notification settings
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SwitchListTile(
                  title: Text('Workout Reminders'),
                  subtitle: Text('Get notified on your workout days'),
                  value:
                      true, // Default to on - would be from preferences in real app
                  onChanged: (bool value) {
                    // Would toggle notifications in a real app
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Notifications ${value ? 'enabled' : 'disabled'}',
                        ),
                      ),
                    );
                  },
                  secondary: Icon(Icons.notifications),
                ),
              ),

              // About section
              _buildSectionHeader('About'),

              // App version
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                  leading: Icon(Icons.info_outline),
                ),
              ),

              // Legal information
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Privacy Policy'),
                      leading: Icon(Icons.privacy_tip),
                      trailing: Icon(Icons.open_in_new),
                      onTap: () {
                        // Would open privacy policy in a real app
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Privacy Policy would open here'),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1),
                    ListTile(
                      title: Text('Terms of Service'),
                      leading: Icon(Icons.article),
                      trailing: Icon(Icons.open_in_new),
                      onTap: () {
                        // Would open terms of service in a real app
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Terms of Service would open here'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Data management section
              _buildSectionHeader('Data Management'),

              // Reset data
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Reset All Data'),
                  subtitle: Text('Delete all workouts and settings'),
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  onTap: () {
                    _showResetConfirmationDialog();
                  },
                ),
              ),

              // Debug section (only in debug mode)
              _buildSectionHeader('Developer Options'),

              // Debug options
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Reset Onboarding'),
                      subtitle: Text('Show onboarding screens again'),
                      leading: Icon(
                        Icons.replay_circle_filled,
                        color: Colors.blue,
                      ),
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('onboarding_completed', false);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Onboarding reset - restart the app to see it',
                            ),
                            action: SnackBarAction(
                              label: 'OK',
                              onPressed: () {},
                            ),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Space at the bottom for better scrolling
              SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  // Build a section header with divider
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 4),
          Divider(height: 1),
        ],
      ),
    );
  }

  String _getThemeText() {
    switch (_currentThemeMode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                ThemeMode.system,
                'System default',
                Icons.brightness_auto,
              ),
              _buildThemeOption(ThemeMode.light, 'Light', Icons.brightness_5),
              _buildThemeOption(ThemeMode.dark, 'Dark', Icons.brightness_3),
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
  }

  Widget _buildThemeOption(ThemeMode mode, String title, IconData icon) {
    return RadioListTile<ThemeMode>(
      title: Row(
        children: [Icon(icon, size: 20), SizedBox(width: 16), Text(title)],
      ),
      value: mode,
      groupValue: _currentThemeMode,
      onChanged: (ThemeMode? value) {
        if (value != null) {
          setState(() {
            _currentThemeMode = value;
          });
          ThemeService.instance.setThemeMode(value);
          Navigator.pop(context);

          // Show confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Theme updated to ${_getThemeText().toLowerCase()}',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reset All Data?'),
            content: Text(
              'This will delete all your workouts and reset the app to default settings. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('RESET', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  // Would actually delete data in a real app
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All data has been reset')),
                  );
                },
              ),
            ],
          ),
    );
  }
}
