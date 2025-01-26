import 'package:flutter/material.dart';
import 'package:smart_todo_app/services/auth_service.dart';
import 'package:smart_todo_app/utils/colors.dart';
import 'package:smart_todo_app/utils/validators.dart';
import 'package:smart_todo_app/widgets/custom_button.dart';
import 'package:smart_todo_app/widgets/custom_text_field.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = await AuthService()
        .signInWithEmail(_emailController.text, _passwordController.text);

    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextFieldInput(
              controller: _emailController,
              icon: Icons.email,
              validator: Validators.validateEmail,
              hintText: 'abc@yourcompany.com',
            ),
            CustomTextFieldInput(
              controller: _passwordController,
              icon: Icons.key,
              validator: Validators.validatePassword,
              isPass: true,
              hintText: 'Password',
            ),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : CustomButton(
                    onTap: _handleLogin,
                    buttonText: 'Login',
                  ),
          ],
        ),
      ),
    );
  }
}
