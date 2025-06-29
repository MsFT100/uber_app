import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery(BuildContext context) async {
    try {
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
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking image: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<bool> _requestAppropriatePermissions(BuildContext context) async {
    if (Platform.isAndroid) {
      final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ (API 33+)
        var status = await Permission.photos.status;
        print('Status: ${status.toString()}');
        if (!status.isGranted) {
          status = await Permission.photos.request();
        } else if (status.isLimited) {
          // Handle limited access if needed
          status = await Permission.photos.request();

        } else if (status.isPermanentlyDenied) {
          _showPermissionDeniedDialog(context);
          return false;
        }

        return status.isGranted;

      } else {
        // Android 6 to 12 (API 23–32)
        var status = await Permission.storage.status;
        print('Status [Android <=12]: ${status.toString()}');

        if (!status.isGranted) {
          status = await Permission.storage.request();
        } else if (status.isLimited) {
          // Handle limited access if needed
          status = await Permission.storage.request();
        } else if (status.isPermanentlyDenied) {
          _showPermissionDeniedDialog(context);
          return false;
        }

        return status.isGranted;
      }

    } else if (Platform.isIOS) {
      var status = await Permission.photosAddOnly.status;

      if (!status.isGranted) {
        status = await Permission.photosAddOnly.request();
      }

      if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog(context);
        return false;
      }
      return status.isGranted;
    }
    return false;
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
