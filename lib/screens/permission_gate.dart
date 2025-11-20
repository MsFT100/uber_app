// check if app has permission to use location
// if false, display this screen

import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'splash.dart';

class LocationPermissionGate extends StatefulWidget {
  const LocationPermissionGate({super.key});

  @override
  State<LocationPermissionGate> createState() => _LocationPermissionGateState();
}

class _LocationPermissionGateState extends State<LocationPermissionGate> {
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final locationStatus = await Permission.location.status;
    final backgroundStatus = await Permission.locationAlways.status;

    if (locationStatus.isGranted && backgroundStatus.isGranted) {
      _navigateToSplash();
    } else {
      _showCustomPermissionPrompt();
    }
  }

  void _navigateToSplash() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Splash()),
    );
  }

  void _showCustomPermissionPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Scaffold(
        backgroundColor: AppConstants.lightPrimary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 80,
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Location Access Needed",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "To serve you better, we need permission to access your location even in the background.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.lock_open,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Grant Access",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();

                    final locationStatus = await Permission.location.request();
                    final backgroundStatus =
                        await Permission.locationWhenInUse.request();

                    if (locationStatus.isGranted &&
                        backgroundStatus.isGranted) {
                      _navigateToSplash();
                    } else if (locationStatus.isPermanentlyDenied ||
                        backgroundStatus.isPermanentlyDenied) {
                      await openAppSettings();
                    } else {
                      _showCustomPermissionPrompt(); // Retry
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Exit App",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightPrimary,
      body: Center(
        child: SpinKitFoldingCube(
          color: Colors.black,
          size: 30.0,
        ),
      ),
    );
  }
}
