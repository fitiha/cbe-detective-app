import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:receipt_validator/views/screens/onboarding_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  static String route = 'setting-page';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
    
          ListTile(
            title: Text("LogOut"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              handleSignOut(context);
            },
          ),
        ],
      ),
    );
  }

  void handleSignOut(BuildContext context) {
    final GetStorage storage = GetStorage();
    try {
      storage.remove('loggedIn');
      storage.remove('onboardingCompleted');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully signed out')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $error')),
      );
    }
  }
}
