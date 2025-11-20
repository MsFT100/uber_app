// check if app has permission to use storage
// if false, display this screen
// if false, request permission
// if granted, proceed to the next screen
// if permanently denied, show a dialog to open app settings

import 'dart:io';

import 'package:BucoRide/screens/auth/registration.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';

class StoragePermissionGate extends StatefulWidget {
  const StoragePermissionGate({super.key});

  @override
  State<StoragePermissionGate> createState() => _StoragePermissionGateState();
}

class _StoragePermissionGateState extends State<StoragePermissionGate> {
  @override
  void initState() {
    super.initState();
    _checkStoragePermission();
  }

  Future<void> _checkStoragePermission() async {

    final storageStatus = await Permission.storage.status;
    final backgroundStatus = await Permission.locationAlways.status;

    if (storageStatus.isGranted && backgroundStatus.isGranted) {
      _navigateToSignupScreen();
    } else {
      _showCustomPermissionPrompt();
    }
  }

  void _navigateToSignupScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RegistrationScreen()),
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
                  Icons.image_rounded,
                  size: 80,
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Storage Access Needed",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "To create an account, we need permission to access your storage so that you can upload your profile picture.",
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

                    if (Platform.isAndroid) {
                      final sdkVersion = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

                      if (sdkVersion >= 33) {
                        // Android 13+ (API 33+)
                        final status = await Permission.photos.status;
                        if (!status.isGranted) {
                          await Permission.photos.request();
                        } else if (status.isGranted) {
                          _navigateToSignupScreen();
                        } else {
                          await openAppSettings();
                        }

                      } else {
                        // Android 6 to 12 (API 23–32)
                        final status = await Permission.storage.status;

                        if (!status.isGranted) {
                          await Permission.storage.request();
                        } else if (status.isGranted) {
                          _navigateToSignupScreen();
                        } else {
                          await openAppSettings();
                        }
                      }
                    } else if (Platform.isIOS) {
                      // iOS specific permission request
                      final status = await Permission.photosAddOnly.status;

                      if (!status.isGranted) {
                        await Permission.photosAddOnly.request();
                      }

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
