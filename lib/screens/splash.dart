import 'dart:async';

import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/screens/home.dart';
import 'package:BucoRide/utils/images.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../providers/user.dart';
import '../utils/app_constants.dart';
import 'auth/login.dart';
import 'intro_pages/OnBoard.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late StreamSubscription<List<ConnectivityResult>> _onConnectivityChanged;
  bool isConnected = false;
  bool isFirst = true;
  bool firstLaunch = false;
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _hideSystemUI();
    if (!GetPlatform.isIOS) {
      _checkConnectivity();
    }
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.repeat(max: 1);
    _controller.forward();

    _route();
  }

  @override
  void dispose() {
    _controller.dispose();
    _onConnectivityChanged.cancel();
    super.dispose();
  }

  void _hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _checkConnectivity() {
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      isConnected = result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi);

      // Show updated SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(
            isConnected ? 'connected'.tr : 'no_connection'.tr,
            textAlign: TextAlign.center,
          ),
        ),
      );

      if (isConnected) {
        _route();
      }

      isFirst = false;
    });
  }

  void _route() async {
    UserProvider auth = Provider.of<UserProvider>(context, listen: false);
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);

    await Future.delayed(Duration(seconds: 10)); // add delay for splash
    while (auth.status == Status.Authenticating) {
      await Future.delayed(
          Duration(milliseconds: 100)); // Wait for authentication
    }
    if (auth.status == Status.Authenticated) {
      // Navigate to Home if authenticated
      changeScreenReplacement(context, HomePage());
    } else {
      // Navigate to Login if not authenticated
      firstLaunch = await appState.checkIfFirstLaunch();

      if (firstLaunch) {
        changeScreenReplacement(context, OnBoarding());
      } else {
        changeScreenReplacement(context, LoginScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppConstants.lightPrimary),
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(
                  transform: Matrix4.translationValues(
                      0,
                      320 -
                          (320 * double.tryParse(_animation.value.toString())!),
                      0),
                  child: Column(
                    children: [
                      Opacity(
                        opacity: _animation.value,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 120 -
                                  ((120 *
                                      double.tryParse(
                                          _animation.value.toString())!))),
                          child: Image.asset(Images.logoWithName, width: 160),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Image.asset(Images.splashBackgroundOne,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 2,
                          fit: BoxFit.cover),
                    ],
                  ),
                ),
                Container(
                  transform: Matrix4.translationValues(0, 20, 0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: (70 *
                            double.tryParse(_animation.value.toString())!)),
                    child: Image.asset(Images.splashBackgroundTwo,
                        width: MediaQuery.of(context).size.width),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
