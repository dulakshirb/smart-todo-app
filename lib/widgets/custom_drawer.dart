import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_todo_app/models/user_model.dart';
import 'package:smart_todo_app/services/auth_service.dart';
import 'package:smart_todo_app/utils/colors.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onDrawerItemSelected;

  const CustomDrawer({super.key, required this.onDrawerItemSelected});

  void _handleItemSelection(BuildContext context, int index) {
    Navigator.pop(context);
    onDrawerItemSelected(index);
  }

  Future<void> _handleLogout(
      BuildContext context, AuthService authService) async {
    await authService.signOut();
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Drawer(
      child: FutureBuilder<UserModel?>(
        future: authService.getCurrentUser(),
        builder: (context, snapshot) {
          final user = snapshot.data;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildUserHeader(user),
              _buildDrawerItem(
                icon: Icons.home,
                title: 'Home',
                onTap: () => _handleItemSelection(context, 0),
              ),
              _buildDrawerItem(
                icon: Icons.person,
                title: 'Profile',
                onTap: () => _handleItemSelection(context, 1),
              ),
              const Divider(),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                color: warningColor,
                onTap: () => _handleLogout(context, authService),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserHeader(UserModel? user) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: primaryColor),
      accountName: Text(user?.name ?? 'Anonymous'),
      accountEmail: Text(user?.email ?? 'No email'),
      currentAccountPicture: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: secondaryColor, width: 5.0),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: user?.profileImageUrl != null
              ? NetworkImage(user!.profileImageUrl!)
              : const AssetImage('assets/default_profile.jpg') as ImageProvider,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
