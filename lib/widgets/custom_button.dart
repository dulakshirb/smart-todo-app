import 'package:flutter/material.dart';
import 'package:smart_todo_app/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String buttonText;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.buttonText,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final buttonColor =
        isEnabled ? backgroundColor ?? primaryColor : Colors.grey;
    final textStyle = TextStyle(
      color: isEnabled
          ? textColor ?? Colors.white
          : const Color.fromARGB(126, 255, 255, 255),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            color: buttonColor,
          ),
          child: Text(buttonText, style: textStyle),
        ),
      ),
    );
  }
}
