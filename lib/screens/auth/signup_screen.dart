import 'package:flutter/material.dart';
import 'package:smart_todo_app/services/auth_service.dart';
import 'package:smart_todo_app/utils/colors.dart';
import 'package:smart_todo_app/utils/validators.dart';
import 'package:smart_todo_app/widgets/custom_button.dart';
import 'package:smart_todo_app/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = await AuthService().signUpWithEmail(
        _nameController.text, _emailController.text, _passwordController.text);

    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup failed. Please try again.'),
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
              controller: _nameController,
              hintText: 'John Doe',
              icon: Icons.person,
              validator: Validators.validateName,
            ),
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
                    onTap: _handleSignup,
                    buttonText: 'Sign Up',
                  ),
          ],
        ),
      ),
    );
  }
}
