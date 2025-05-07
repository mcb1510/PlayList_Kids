import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'kidsLoginPage.dart';
import 'profileSelection.dart';
import 'home.dart';
import 'onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LaunchGate(),
    );
  }
}

class LaunchGate extends StatelessWidget {
  const LaunchGate({super.key});

  Future<Widget> _determineStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final selectedProfile = prefs.getString('selectedProfile');
    final onboardingSeen = prefs.getBool('onboardingSeen') ?? false;

    if (!onboardingSeen) {
      // 🟣 First install, show onboarding
      await prefs.setBool('onboardingSeen', true);
      return OnboardingScreen();
    }

    if (user == null) {
      return KidsLoginPage(); // Not logged in
    } else if (selectedProfile == null) {
      return profileSelection(); // Logged in, no profile selected yet
    } else {
      return HomePage(); // Logged in and profile already selected
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineStartScreen(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        return snapshot.data!;
      },
    );
  }
}
