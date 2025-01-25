import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_todo_app/services/auth_service.dart';
import 'package:smart_todo_app/utils/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return FutureBuilder(
      future: authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        return Scaffold(
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                CircleAvatar(
                  radius: 55,
                  backgroundColor: secondaryColor,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: (user?.profileImageUrl != null &&
                            user!.profileImageUrl!.isNotEmpty)
                        ? NetworkImage(user.profileImageUrl!)
                        : AssetImage('assets/default_profile.jpg')
                            as ImageProvider,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  user?.name ?? 'User',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  user?.email ?? 'No email',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
