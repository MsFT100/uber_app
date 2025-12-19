import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    as ph; // Alias to avoid conflict with our enum

// An enum to make the status of a permission clear and type-safe
enum PermissionStatus { granted, denied, permanentlyDenied, unknown }

class PermissionsService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// --- Location Permissions ---

  /// Checks the current status of the location permission.
  Future<PermissionStatus> checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return _convertGeolocatorPermission(permission);
  }

  /// Requests location permission from the user.
  /// Returns the status after the user has made a choice.
  Future<PermissionStatus> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return _convertGeolocatorPermission(permission);
  }

  /// Checks if the location service (GPS) is enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Helper method to convert Geolocator's enum to our custom one.
  PermissionStatus _convertGeolocatorPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return PermissionStatus.granted;
      case LocationPermission.denied:
        return PermissionStatus.denied;
      case LocationPermission.deniedForever:
        return PermissionStatus.permanentlyDenied;
      default:
        return PermissionStatus.unknown;
    }
  }

  /// --- Notification Permissions ---

  /// Requests notification permission from the user on iOS and web.
  /// Android 13+ also requires this.
  Future<PermissionStatus> requestNotificationPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional:
          false, // Provisional allows notifications without explicit user consent on iOS
    );
    return _convertFCMAuthStatus(settings.authorizationStatus);
  }

  // Helper method to convert FCM's enum to our custom one.
  PermissionStatus _convertFCMAuthStatus(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return PermissionStatus.granted;
      case AuthorizationStatus.denied:
        return PermissionStatus.denied;
      default:
        return PermissionStatus.unknown;
    }
  }

  /// --- Media/Storage Permissions ---

  /// Requests permission to access media (images/photos).
  /// This handles READ_MEDIA_IMAGES for Android 13+ and READ_EXTERNAL_STORAGE for older Android for photos.
  Future<PermissionStatus> requestMediaImagesPermission() async {
    final ph.PermissionStatus status = await ph.Permission.photos.request();
    return _convertPermissionHandlerStatus(status);
  }

  /// Requests permission to access the camera.
  Future<PermissionStatus> requestCameraPermission() async {
    final ph.PermissionStatus status = await ph.Permission.camera.request();
    return _convertPermissionHandlerStatus(status);
  }

  /// Helper method to convert permission_handler's enum to our custom one.
  PermissionStatus _convertPermissionHandlerStatus(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
      case ph.PermissionStatus
            .limited: // Limited access on iOS is still considered granted for picking images
        return PermissionStatus.granted;
      case ph.PermissionStatus.denied:
        return PermissionStatus.denied;
      case ph.PermissionStatus.permanentlyDenied:
      case ph.PermissionStatus
            .restricted: // On iOS, restricted means parental controls etc., treat as permanently denied for user action
        return PermissionStatus.permanentlyDenied;
      default:
        return PermissionStatus.unknown;
    }
  }
}
