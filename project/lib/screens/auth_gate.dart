import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happiness_hub/screens/login_page.dart';
import 'package:happiness_hub/screens/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot is still waiting for data, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If the user is logged in (snapshot has data)
        if (snapshot.hasData) {
          // Navigate to the main content of the app
          return const MainScreen();
        }

        // If the user is not logged in
        return const LoginPage();
      },
    );
  }
}
