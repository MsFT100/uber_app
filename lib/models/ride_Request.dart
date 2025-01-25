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
  late final String _id;
  late final String _username;
  late final String _userId;
  String? _driverId; // Nullable
  late final String _status;
  late final Map _position;
  late final Map _destination;

  // Getters
  String get id => _id;
  String get username => _username;
  String get userId => _userId;
  String? get driverId => _driverId; // Nullable
  String get status => _status;
  Map get position => _position;
  Map get destination => _destination;

  // Constructor for creating the object from Firestore snapshot
  RideRequestModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data =
        snapshot.data() as Map<String, dynamic>?; // Ensure data is not null
    _id = data?[ID] ?? ''; // Default to empty string if null
    _username = data?[USERNAME] ?? '';
    _userId = data?[USER_ID] ?? '';
    _driverId = data?[DRIVER_ID]; // Nullable
    _status = data?[STATUS] ?? '';
    _position = data?[POSITION] ?? {};
    _destination = data?[DESTINATION] ?? {};
  }
}
