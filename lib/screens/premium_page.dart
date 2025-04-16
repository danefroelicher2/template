// lib/screens/premium_page.dart
import 'package:flutter/material.dart';
import '../services/subscription_service.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  _PremiumPageState createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  bool _isPremium = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
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
      appBar: AppBar(title: Text('Upgrade to Pro')),
      body: _isPremium ? _buildAlreadyPremium() : _buildPremiumOffer(),
    );
  }

  Widget _buildAlreadyPremium() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 64),
          SizedBox(height: 16),
          Text(
            'You\'re a Pro User!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'You have access to all premium features.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            child: Text('RETURN TO HOME'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumOffer() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Upgrade to GymTracker Pro',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          // Feature comparison
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFeatureRow('Basic Workout Tracking', true, true),
                  Divider(),
                  _buildFeatureRow('Workout History', true, true),
                  Divider(),
                  _buildFeatureRow('Basic Exercise Library', true, true),
                  Divider(),
                  _buildFeatureRow('Premium Exercises', false, true),
                  Divider(),
                  _buildFeatureRow('Analytics Dashboard', false, true),
                  Divider(),
                  _buildFeatureRow('Progress Charts', false, true),
                  Divider(),
                  _buildFeatureRow('Export Data', false, true),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Pricing
          Text(
            'Only \$4.99/month',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8),

          Text(
            'Or \$39.99/year (save 33%)',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 24),

          // Upgrade button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed:
                _isLoading
                    ? null
                    : () async {
                      setState(() {
                        _isLoading = true;
                      });

                      // In a real app, this would handle payment processing
                      await Future.delayed(Duration(seconds: 2));
                      await SubscriptionService.upgradeToPremium();

                      setState(() {
                        _isPremium = true;
                        _isLoading = false;
                      });

                      // Show success dialog
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text('Upgrade Successful'),
                              content: Text(
                                'You now have access to all Pro features!',
                              ),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                      );
                    },
            child:
                _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('UPGRADE NOW', style: TextStyle(fontSize: 16)),
          ),

          SizedBox(height: 16),

          TextButton(
            child: Text('Restore Purchase'),
            onPressed: () {
              // In a real app, this would check for existing purchases
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No previous purchases found')),
              );
            },
          ),

          SizedBox(height: 8),

          Text(
            'This is a demo app. No actual payment will be processed.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, bool inFree, bool inPro) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(feature)),
          SizedBox(width: 8),
          Column(
            children: [
              Text('FREE', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 4),
              Icon(
                inFree ? Icons.check_circle : Icons.cancel,
                color: inFree ? Colors.green : Colors.red,
              ),
            ],
          ),
          SizedBox(width: 16),
          Column(
            children: [
              Text('PRO', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 4),
              Icon(
                inPro ? Icons.check_circle : Icons.cancel,
                color: inPro ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
