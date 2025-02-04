import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dd_smart_todo_app/providers/auth_provider.dart';

class UserInfoHeader extends StatefulWidget {
  final double? width;
  const UserInfoHeader({super.key, this.width});

  @override
  State<UserInfoHeader> createState() => _UserInfoHeaderState();
}

class _UserInfoHeaderState extends State<UserInfoHeader> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _buildAvatar(
      BuildContext context, String displayName, String? photoURL) {
    return photoURL != null && photoURL.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: photoURL,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundImage: imageProvider,
              radius: 20,
            ),
            placeholder: (context, url) =>
                _buildInitialAvatar(context, displayName),
            errorWidget: (context, url, error) =>
                _buildInitialAvatar(context, displayName),
          )
        : _buildInitialAvatar(context, displayName);
  }

  Widget _buildInitialAvatar(BuildContext context, String displayName) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).primaryColor,
      radius: 20,
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    final formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(_currentTime);

    return Container(
      width: widget.width,
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          _buildAvatar(context, user.displayName, user.photoURL),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formattedTime,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
