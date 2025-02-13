import 'package:flutter/material.dart';

import 'custom_text.dart'; // Adjust this path based on your project structure.

class CustomBtn extends StatelessWidget {
  final String text;
  final Color? txtColor;
  final Color? bgColor;
  final Color? shadowColor;
  final VoidCallback onTap;

  const CustomBtn({
    Key? key,
    required this.text,
    this.txtColor,
    this.bgColor,
    this.shadowColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: bgColor ?? Colors.black,
          boxShadow: [
            BoxShadow(
              color: (shadowColor ?? Colors.grey),
              offset: const Offset(2, 3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: CustomText(
            text: text,
            color: txtColor ?? Colors.white,
            size: 22,
            weight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
