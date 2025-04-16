// lib/screens/profile_page.dart
// ignore_for_file: use_build_context_synchronously, use_super_parameters

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/subscription_service.dart';
import 'premium_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isPremium = false;
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkPremiumStatus() async {
    final isPremium = await SubscriptionService.isPremium();
    if (mounted) {
      setState(() {
        _isPremium = isPremium;
      });
    }
  }

  void _loadUserProfile() {
    final profile = Provider.of<AuthProvider>(context, listen: false).profile;
    if (profile != null) {
      if (profile.displayName != null) {
        _nameController.text = profile.displayName!;
      }
      if (profile.email != null) {
        _emailController.text = profile.email!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.profile;

    return Scaffold(
      appBar: AppBar(title: Text('My Profile')),
      body:
          profile == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header
                    Center(
                      child: Column(
                        children: [
                          // Profile avatar
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue.shade100,
                            child:
                                profile.photoURL != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        profile.photoURL!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(Icons.person, size: 50),
                                      ),
                                    )
                                    : Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.blue,
                                    ),
                          ),
                          SizedBox(height: 16),

                          // User name
                          Text(
                            profile.displayName ?? 'User',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),

                          // User email
                          Text(
                            profile.email ?? 'Guest User',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),

                          // Member type
                          Chip(
                            label: Text(
                              _isPremium ? 'PRO Member' : 'Free User',
                              style: TextStyle(
                                color: _isPremium ? Colors.white : Colors.black,
                              ),
                            ),
                            backgroundColor:
                                _isPremium ? Colors.blue : Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // Account settings section
                    if (!profile.isGuest) ...[
                      Text(
                        'Account Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Edit display name
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Edit Display Name'),
                        trailing: Icon(Icons.edit),
                        onTap: _showEditNameDialog,
                      ),
                      Divider(),

                      // Change password (only for email/password users)
                      ListTile(
                        leading: Icon(Icons.lock),
                        title: Text('Change Password'),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Show password reset dialog
                          _showPasswordResetDialog();
                        },
                      ),
                      Divider(),
                    ],

                    // Subscription section
                    Text(
                      'Subscription',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Manage subscription
                    ListTile(
                      leading: Icon(Icons.star),
                      title: Text(
                        _isPremium ? 'Manage Subscription' : 'Upgrade to Pro',
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PremiumPage(),
                          ),
                        ).then((_) => _checkPremiumStatus());
                      },
                    ),
                    Divider(),

                    SizedBox(height: 32),

                    // Sign out button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed:
                            _isLoading
                                ? null
                                : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  await authProvider.signOut();

                                  setState(() {
                                    _isLoading = false;
                                  });
                                },
                        icon: Icon(Icons.logout),
                        label:
                            _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),

                    if (profile.isGuest) ...[
                      SizedBox(height: 16),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Show convert guest account dialog
                            _showConvertGuestDialog();
                          },
                          icon: Icon(Icons.person_add),
                          label: Text('Create Permanent Account'),
                        ),
                      ),
                    ],

                    // Delete account option
                    if (!profile.isGuest) ...[
                      SizedBox(height: 32),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Show delete account confirmation dialog
                            _showDeleteAccountDialog();
                          },
                          child: Text(
                            'Delete Account',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  // Edit name dialog
  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Display Name'),
            content: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your display name',
              ),
            ),
            actions: [
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              Consumer<AuthProvider>(
                builder:
                    (context, authProvider, _) => TextButton(
                      onPressed:
                          authProvider.isLoading
                              ? null
                              : () async {
                                if (_nameController.text.isNotEmpty) {
                                  final success = await authProvider
                                      .updateProfile(
                                        displayName:
                                            _nameController.text.trim(),
                                      );

                                  Navigator.pop(context);

                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Display name updated successfully',
                                        ),
                                      ),
                                    );
                                  } else if (authProvider.error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(authProvider.error!),
                                      ),
                                    );
                                  }
                                } else {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Display name cannot be empty',
                                      ),
                                    ),
                                  );
                                }
                              },
                      child: Text('SAVE'),
                    ),
              ),
            ],
          ),
    );
  }

  // Password reset dialog
  void _showPasswordResetDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profile = authProvider.profile;

    if (profile == null || profile.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No email associated with this account')),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reset Password'),
            content: Text(
              'We will send a password reset link to ${profile.email}. '
              'Do you want to continue?',
            ),
            actions: [
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('SEND LINK'),
                onPressed: () async {
                  Navigator.pop(context);

                  final success = await authProvider.resetPassword(
                    profile.email!,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Password reset email sent. Please check your inbox.',
                        ),
                      ),
                    );
                  } else if (authProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authProvider.error!)),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  // Convert guest account dialog
  void _showConvertGuestDialog() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Create Account'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Create a password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Confirm your password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('CANCEL'),
                  onPressed: () => Navigator.pop(context),
                ),
                Consumer<AuthProvider>(
                  builder:
                      (context, authProvider, _) => TextButton(
                        onPressed:
                            authProvider.isLoading
                                ? null
                                : () async {
                                  if (formKey.currentState!.validate()) {
                                    final success = await authProvider
                                        .convertGuestAccount(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                        );

                                    Navigator.pop(context);

                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Account created successfully! Please verify your email.',
                                          ),
                                        ),
                                      );
                                    } else if (authProvider.error != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(authProvider.error!),
                                        ),
                                      );
                                    }
                                  }
                                },
                        child: Text('CREATE'),
                      ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Delete account confirmation dialog
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Account'),
            content: Text(
              'Are you sure you want to delete your account? '
              'This action cannot be undone and all your data will be permanently lost.',
            ),
            actions: [
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              Consumer<AuthProvider>(
                builder:
                    (context, authProvider, _) => TextButton(
                      onPressed:
                          authProvider.isLoading
                              ? null
                              : () async {
                                try {
                                  Navigator.pop(context);

                                  // Show loading dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder:
                                        (context) => AlertDialog(
                                          content: Row(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(width: 16),
                                              Text('Deleting account...'),
                                            ],
                                          ),
                                        ),
                                  );

                                  // Actually delete the account
                                  await authProvider.deleteAccount();

                                  // Close loading dialog and navigate back
                                  Navigator.of(context).pop();

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Account deleted successfully',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  // Close loading dialog if open
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop();

                                  // Show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to delete account: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                      child: Text(
                        'DELETE',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
              ),
            ],
          ),
    );
  }
}
