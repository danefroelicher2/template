// lib/screens/auth/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App name or logo
              Center(
                child: Text(
                  'GymTracker Pro',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 30),

              // Name field (optional)
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Display Name (Optional)',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 16),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
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

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
                obscureText: _obscurePassword,
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

              // Confirm password field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
                obscureText: _obscureConfirmPassword,
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
              SizedBox(height: 16),

              // Terms and conditions
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'I accept the Terms and Conditions and Privacy Policy',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Sign up button
              ElevatedButton(
                onPressed:
                    (!_acceptTerms || authProvider.isLoading)
                        ? null
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            // First create the account
                            final success = await authProvider.signUpWithEmail(
                              _emailController.text.trim(),
                              _passwordController.text,
                            );

                            if (success) {
                              // If name was provided, update profile
                              if (_nameController.text.isNotEmpty) {
                                await authProvider.updateProfile(
                                  displayName: _nameController.text.trim(),
                                );
                              }

                              // Show verification email sent dialog
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text('Account Created'),
                                      content: Text(
                                        'Your account has been created successfully. '
                                        'A verification email has been sent to your email address.',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.pop(
                                              context,
                                            ); // Close dialog
                                            Navigator.pop(
                                              context,
                                            ); // Return to sign in screen
                                          },
                                        ),
                                      ],
                                    ),
                              );
                            } else if (authProvider.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(authProvider.error!)),
                              );
                            }
                          }
                        },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child:
                    authProvider.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
              SizedBox(height: 20),

              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
