import 'package:flutter/cupertino.dart';

class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40); // Start at the bottom-left
    path.quadraticBezierTo(size.width / 2, size.height, size.width,
        size.height - 40); // Create a smooth curve
    path.lineTo(size.width, 0); // Go to the top-right
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
