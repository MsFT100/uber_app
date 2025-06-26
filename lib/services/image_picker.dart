import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
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
      final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ (API 33+): Use READ_MEDIA_IMAGES
        final mediaImagesPermission = await Permission.photos.request();
        final mediaLibraryPermission = await Permission.mediaLibrary.request();
        return mediaImagesPermission.isGranted || mediaLibraryPermission.isGranted;

      } else {
        // Android 6 to 12 (API 23–32): Use READ_EXTERNAL_STORAGE
        final storagePermission = await Permission.storage.request();
        final mediaLibraryPermission = await Permission.mediaLibrary.request();

        return storagePermission.isGranted || mediaLibraryPermission.isGranted;
      }
    } else if (Platform.isIOS) {
      final photosPermission = await Permission.photosAddOnly.request();
      return photosPermission.isGranted;
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
            "Image access permission was denied. Please enable it from settings.",
          ),
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
