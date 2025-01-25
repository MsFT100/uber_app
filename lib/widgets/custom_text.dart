import 'package:flutter/material.dart';

import '../helpers/style.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final FontWeight weight;

  // Named constructor with required `text` and default values for other parameters
  const CustomText({
    Key? key,
    required this.text,
    this.size = 16.0, // Default font size
    this.color = black, // Default color from your style file
    this.weight = FontWeight.normal, // Default weight
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
      ),
    );
  }
}
