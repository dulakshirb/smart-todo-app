import 'package:flutter/material.dart';
import 'package:smart_todo_app/utils/colors.dart';

class CustomTextFieldInputWithoutPadding extends StatelessWidget {
  final TextEditingController? controller;
  final bool isPass;
  final TextInputType keyboardType;
  final String hintText;
  final IconData icon;
  final String? Function(String?)? validator;

  const CustomTextFieldInputWithoutPadding({
    super.key,
    required this.controller,
    this.isPass = false,
    this.keyboardType = TextInputType.text,
    required this.hintText,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPass,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: accentColor),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: InputBorder.none,
        filled: true,
        fillColor: backgroundColor,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: secondaryColor),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
