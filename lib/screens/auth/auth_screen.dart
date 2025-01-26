import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smart_todo_app/screens/auth/signin_screen.dart';
import 'package:smart_todo_app/screens/auth/signup_screen.dart';
import 'package:smart_todo_app/services/auth_service.dart';
import 'package:smart_todo_app/utils/colors.dart';
import 'package:smart_todo_app/utils/styles.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignInScreen = true;
  bool _isGoogleLoading = false;

  void _toggleScreen() {
    setState(() => _isSignInScreen = !_isSignInScreen);
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);

    final user = await AuthService().signInWithGoogle();

    setState(() => _isGoogleLoading = false);

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Image.asset(
                    'assets/login.jpg',
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 10),
                  _isSignInScreen ? const SigninScreen() : const SignupScreen(),
                  const SizedBox(height: 20),
                  _buildDividerSection(),
                  const SizedBox(height: 10),
                  Text('Login with your social network', style: normalText),
                  const SizedBox(height: 20),
                  _buildGoogleLoginButton(),
                  const SizedBox(height: 30),
                  const Spacer(),
                  _buildToggleSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: 0.5, color: Colors.grey.shade400)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text("OR", style: TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Divider(thickness: 0.5, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return _isGoogleLoading
        ? const CircularProgressIndicator(color: primaryColor)
        : GestureDetector(
            onTap: _handleGoogleLogin,
            child: Image.asset(
              'assets/google.png',
              height: 40,
              semanticLabel: 'Google Login',
            ),
          );
  }

  Widget _buildToggleSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: _isSignInScreen
                  ? "Don't have an account? "
                  : "Already have an account? ",
              style: normalText,
            ),
            TextSpan(
              text: _isSignInScreen ? "Sign Up" : "Sign In",
              style: clickableText,
              recognizer: TapGestureRecognizer()..onTap = _toggleScreen,
            ),
          ],
        ),
      ),
    );
  }
}
