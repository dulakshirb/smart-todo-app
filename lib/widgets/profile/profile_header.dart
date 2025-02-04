
import 'package:flutter/material.dart';
import 'package:dd_smart_todo_app/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAvatar(),
        const SizedBox(height: 16),
        Text(
          user.displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 4,
        ),
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        child: user.photoURL != null && user.photoURL!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: user.photoURL!,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => _buildInitialAvatar(),
                errorWidget: (context, url, error) => _buildInitialAvatar(),
              )
            : _buildInitialAvatar(),
      ),
    );
  }

  Widget _buildInitialAvatar() {
    return Text(
      user.displayName[0].toUpperCase(),
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}