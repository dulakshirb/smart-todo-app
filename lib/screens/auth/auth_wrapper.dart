import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dd_smart_todo_app/providers/auth_provider.dart';
import 'package:dd_smart_todo_app/screens/auth/auth_screen.dart';
import 'package:dd_smart_todo_app/screens/home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (auth.currentUser == null) {
          return const AuthScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
