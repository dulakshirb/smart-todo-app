import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirm',
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: isDestructive ? Colors.red : null,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
