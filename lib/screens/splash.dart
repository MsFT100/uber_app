import 'package:flutter/material.dart';

import '../utils/app_constants.dart';
import '../utils/images.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightPrimary, // Using a constant for the background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Images.logoWithName, 
              width: MediaQuery.of(context).size.width * 0.6, // Responsive width
            ),
            const SizedBox(height: 24),
            const Text(
              'Effortless Rides, Every Time', 
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



