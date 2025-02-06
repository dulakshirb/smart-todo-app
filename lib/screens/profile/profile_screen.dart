import 'package:dd_smart_todo_app/providers/category_provider.dart';
import 'package:dd_smart_todo_app/providers/task_provider.dart';
import 'package:dd_smart_todo_app/screens/auth/auth_wrapper.dart';
import 'package:dd_smart_todo_app/screens/profile/edit_profile_screen.dart';
import 'package:dd_smart_todo_app/screens/settings/notification_settings.screen.dart';
import 'package:dd_smart_todo_app/widgets/confirmation_dialog.dart';
import 'package:dd_smart_todo_app/widgets/loading_overlay.dart';
import 'package:dd_smart_todo_app/widgets/profile/profile_header.dart';
import 'package:dd_smart_todo_app/widgets/profile/profile_menu_item.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dd_smart_todo_app/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDeleting = false;

  Future<void> _handleDeleteProfile() async {
    setState(() => _isDeleting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.deleteProfile();

      if (!mounted) return;

      // Clear provider states
      context.read<TaskProvider>().updateUserId(null);
      context.read<CategoryProvider>().updateUserId(null);

      // Navigate to auth wrapper
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in again to delete your account.'),
            duration: Duration(seconds: 5),
          ),
        );

        await context.read<AuthProvider>().signOut();

        if (!mounted) return;

        // Navigate to auth wrapper
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _confirmAndDelete() {
    if (_isDeleting) return;

    showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Delete Profile',
        content:
            'Are you sure you want to delete your profile? This will permanently delete all your tasks and categories. This action cannot be undone.',
        confirmText: 'Delete',
        isDestructive: true,
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        _handleDeleteProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ProfileHeader(user: user),
              const SizedBox(height: 24),
              ProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              ProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              ProfileMenuItem(
                icon: Icons.security_outlined,
                title: 'Privacy & Security',
                onTap: () {},
              ),
              ProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              ProfileMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                color: Colors.red,
                onTap: () {
                  showDialog<bool>(
                    context: context,
                    builder: (context) => const ConfirmationDialog(
                      title: 'Logout',
                      content: 'Are you sure you want to logout?',
                      confirmText: 'Logout',
                      isDestructive: true,
                    ),
                  ).then((confirmed) {
                    if (confirmed == true && mounted) {
                      context.read<AuthProvider>().signOut();
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              ProfileMenuItem(
                icon: Icons.delete_outline,
                title: 'Delete Profile',
                color: Colors.red,
                enabled: !_isDeleting,
                onTap: _confirmAndDelete,
              ),
            ],
          ),
        ),
        if (_isDeleting)
          const LoadingOverlay(
            message: 'Deleting profile...',
          ),
      ],
    );
  }
}
