import 'package:flutter/material.dart';
import 'package:smart_todo_app/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String buttonText;
  const CustomButton(
      {super.key, required this.onTap, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: primaryColor),
          child: Text(buttonText,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
