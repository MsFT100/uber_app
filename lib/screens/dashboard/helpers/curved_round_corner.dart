import 'package:flutter/cupertino.dart';

class RoundedCornersAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double cornerRadius = 50.0; // Adjust the corner radius as needed

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - cornerRadius) // Left side
      ..quadraticBezierTo(
        0,
        size.height,
        cornerRadius,
        size.height, // Bottom-left corner curve
      )
      ..lineTo(size.width - cornerRadius, size.height) // Bottom straight line
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width,
        size.height - cornerRadius, // Bottom-right corner curve
      )
      ..lineTo(size.width, 0) // Right side
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
