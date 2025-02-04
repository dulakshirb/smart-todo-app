import 'package:dd_smart_todo_app/screens/profile/edit_profile_screen.dart';
import 'package:dd_smart_todo_app/screens/settings/notification_settings.screen.dart';
import 'package:dd_smart_todo_app/widgets/confirmation_dialog.dart';
import 'package:dd_smart_todo_app/widgets/profile/profile_header.dart';
import 'package:dd_smart_todo_app/widgets/profile/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dd_smart_todo_app/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return SingleChildScrollView(
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
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => const ConfirmationDialog(
                  title: 'Logout',
                  content: 'Are you sure you want to logout?',
                  confirmText: 'Logout',
                  isDestructive: true,
                ),
              );

              if (confirm == true && context.mounted) {
                await context.read<AuthProvider>().signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
