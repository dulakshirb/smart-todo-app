import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_todo_app/models/user_model.dart';
import 'package:smart_todo_app/services/auth_service.dart';
import 'package:smart_todo_app/utils/colors.dart';
import 'package:smart_todo_app/utils/validators.dart';
import 'package:smart_todo_app/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _currentName;
  bool _isUpdateButtonEnabled = false;
  UserModel? _user;
  bool _isLoading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _currentName = '';
    _fetchUserData();

    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        user != null
            ? _fetchUserData()
            : setState(() {
                _user = null;
                _isLoading = false;
              });
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final user = await AuthService().getCurrentUser();
    if (user != null) {
      setState(() {
        _user = user;
        _nameController.text = user.name;
        _currentName = user.name;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate() && _user != null) {
      final updatedUser = UserModel(
        id: _user!.id,
        name: _nameController.text,
        email: _user!.email,
        profileImageUrl: _user!.profileImageUrl,
      );

      await AuthService().updateProfile(updatedUser);

      setState(() {
        _currentName = _nameController.text;
        _isUpdateButtonEnabled = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AuthService().deleteUser();
        Navigator.pushReplacementNamed(context, '/auth');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: secondaryColor,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: (_user?.profileImageUrl != null &&
                                  _user!.profileImageUrl!.isNotEmpty)
                              ? NetworkImage(_user!.profileImageUrl!)
                              : const AssetImage('assets/default_profile.jpg')
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFormField(
                          controller: _nameController,
                          validator: Validators.validateName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter your name',
                            hintStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            alignLabelWithHint: true,
                          ),
                          textAlign: TextAlign.center,
                          onChanged: (value) => setState(() {
                            _isUpdateButtonEnabled = value != _currentName;
                          }),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _user?.email ?? 'No email',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Expanded(child: SizedBox()),
                      CustomButton(
                        onTap: _isUpdateButtonEnabled ? _updateProfile : null,
                        buttonText: 'Update',
                      ),
                      CustomButton(
                        onTap: _deleteAccount,
                        buttonText: 'Delete Account',
                        backgroundColor: Colors.red,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
