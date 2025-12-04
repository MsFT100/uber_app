import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';

class MapActionButton extends StatelessWidget {
  final double top;
  final double left;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const MapActionButton({
    super.key,
    required this.top,
    required this.left,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppConstants.lightPrimary,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade600,
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }
}