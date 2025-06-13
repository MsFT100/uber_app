import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_constants.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery(BuildContext context) async {
    bool hasPermission = await _requestAppropriatePermissions(context);
    if (!hasPermission) {
      _showPermissionDeniedDialog(context);
      return null;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<bool> _requestAppropriatePermissions(BuildContext context) async {
    if (Platform.isAndroid) {
      if (await Permission.photos.request().isGranted) return true;

      // Try fallback for Android 12 and below
      if (await Permission.storage.request().isGranted) return true;
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: AppConstants.lightPrimary,
        body: AlertDialog(
          title: const Text("Permission Denied"),
          content: const Text(
              "Image access permission was denied. Please enable it from settings."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text("Open Settings"),
            ),
          ],
        ),
      ),
    );
  }
}
