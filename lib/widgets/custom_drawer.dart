import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_todo_app/models/user_model.dart';
import 'package:smart_todo_app/services/auth_service.dart';
import 'package:smart_todo_app/utils/colors.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onDrawerItemSelected;

  const CustomDrawer({super.key, required this.onDrawerItemSelected});

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
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: primaryColor),
                accountName: Text(
                  user?.name ?? 'Anonymous',
                ),
                accountEmail: Text(
                  user?.email ?? 'No email',
                ),
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: secondaryColor,
                      width: 5.0,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: user?.profileImageUrl != null
                        ? NetworkImage(user!.profileImageUrl!)
                        : AssetImage('assets/default_profile.jpg')
                            as ImageProvider,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  onDrawerItemSelected(0);
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  onDrawerItemSelected(1);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: warningColor),
                title: Text(
                  'Logout',
                  style: TextStyle(color: warningColor),
                ),
                onTap: () async {
                  await authService.signOut();
                  Navigator.pushReplacementNamed(context, '/auth');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
