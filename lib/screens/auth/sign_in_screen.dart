// lib/screens/auth/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or app name
              Center(
                child: Text(
                  'GymTracker Pro',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 40),

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
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),

              // Remember me and Forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      Text('Remember me'),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      _showForgotPasswordDialog();
                    },
                    child: Text('Forgot password?'),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Sign in button
              ElevatedButton(
                onPressed:
                    authProvider.isLoading
                        ? null
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await authProvider.signInWithEmail(
                              _emailController.text.trim(),
                              _passwordController.text,
                            );

                            if (success) {
                              Navigator.of(context).pop(); // Return to wrapper
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
                        : Text('SIGN IN', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 20),

              // Sign in with Google
              OutlinedButton.icon(
                onPressed:
                    authProvider.isLoading
                        ? null
                        : () async {
                          final success = await authProvider.signInWithGoogle();

                          if (success) {
                            Navigator.of(context).pop(); // Return to wrapper
                          } else if (authProvider.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(authProvider.error!)),
                            );
                          }
                        },
                icon: Image.asset(
                  'assets/google_logo.png',
                  height: 24,
                  // If asset is not available, show icon instead
                  errorBuilder: (ctx, error, _) => Icon(Icons.g_mobiledata),
                ),
                label: Text('Sign in with Google'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              SizedBox(height: 20),

              // Guest mode
              TextButton(
                onPressed:
                    authProvider.isLoading
                        ? null
                        : () async {
                          final success = await authProvider.signInAsGuest();

                          if (success) {
                            Navigator.of(context).pop(); // Return to wrapper
                          } else if (authProvider.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(authProvider.error!)),
                            );
                          }
                        },
                child: Text('Continue as guest'),
              ),
              SizedBox(height: 20),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text('Sign up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reset Password'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
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
                                      .resetPassword(
                                        emailController.text.trim(),
                                      );

                                  Navigator.pop(context);

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
                                      SnackBar(
                                        content: Text(authProvider.error!),
                                      ),
                                    );
                                  }
                                }
                              },
                      child: Text('RESET'),
                    ),
              ),
            ],
          ),
    );
  }
}
