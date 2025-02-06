import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final bool enabled;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        onTap: enabled ? onTap : null,
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
