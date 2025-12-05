import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/app_constants.dart';
import '../utils/images.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const SplashScreen({Key? key, this.onComplete}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _bottomTextAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar color to match splash
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppConstants.lightPrimary,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Scale animation for logo
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Fade animation for logo
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Slide animation for logo
    _slideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Background color pulse animation
    _colorAnimation = ColorTween(
      begin: AppConstants.lightPrimary,
      end: Color.lerp(AppConstants.lightPrimary, Colors.orange.shade700, 0.1),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Text slide animation
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    // Bottom text fade animation
    _bottomTextAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation sequence
    _controller.forward();

    // Listen for animation completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Add a slight delay before navigating
        Timer(const Duration(milliseconds: 500), () {
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _colorAnimation.value,
          body: Stack(
            children: [
              // Background with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      _colorAnimation.value!,
                      Color.lerp(_colorAnimation.value!, Colors.black, 0.05)!,
                    ],
                    stops: const [0.7, 1.0],
                  ),
                ),
              ),

              // Main content (centered)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo container with multiple effects
                    Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withAlpha(26), // Replaced withOpacity
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha(26), // Replaced withOpacity
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white
                                      .withAlpha(26), // Replaced withOpacity
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              Images.logoWithName,
                              width: size.width * 0.6,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Animated tagline
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor: Colors.grey.shade400,
                              period: const Duration(milliseconds: 2000),
                              child: const Text(
                                'Effortless Rides, Every Time',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                  // The color is now controlled by the shimmer effect
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Animated loading indicator
                            if (_controller.value > 0.7)
                              SizedBox(
                                width: 100,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.white
                                      .withAlpha(51), // Replaced withOpacity
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white
                                        .withAlpha(204), // Replaced withOpacity
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom text (positioned at the bottom)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _bottomTextAnimation.value,
                  child: Text(
                    'BUCO RIDE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
