import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequestModel {
  static const String ID = "id";
  static const String USERNAME = "username";
  static const String USER_ID = "userId";
  static const String DRIVER_ID = "driverId";
  static const String STATUS = "status";
  static const String POSITION = "position";
  static const String DESTINATION = "destination";

  // Fields
  final String id;
  final String username;
  final String userId;
  final String? driverId; // Nullable
  final String status;
  final Map<String, dynamic> position;
  final Map<String, dynamic> destination;

  // Constructor from Firestore snapshot
  RideRequestModel.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot[ID] ?? '',
        username = snapshot[USERNAME] ?? '',
        userId = snapshot[USER_ID] ?? '',
        driverId = snapshot[DRIVER_ID], // Nullable
        status = snapshot[STATUS] ?? '',
        position = Map<String, dynamic>.from(snapshot[POSITION] ?? {}),
        destination = Map<String, dynamic>.from(snapshot[DESTINATION] ?? {});

  // ✅ Custom constructor to create from a Map
  RideRequestModel.fromMap(Map<String, dynamic> data)
      : id = data[ID] ?? '',
        username = data[USERNAME] ?? '',
        userId = data[USER_ID] ?? '',
        driverId = data[DRIVER_ID],
        status = data[STATUS] ?? '',
        position = Map<String, dynamic>.from(data[POSITION] ?? {}),
        destination = Map<String, dynamic>.from(data[DESTINATION] ?? {});
}
