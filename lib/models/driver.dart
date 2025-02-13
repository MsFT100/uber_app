import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverModel {
  static const ID = "id";
  static const NAME = "name";
  static const LATITUDE = "latitude";
  static const LONGITUDE = "longitude";
  static const HEADING = "heading";
  static const POSITION = "position";
  static const CAR = "car";
  static const PLATE = "plate";
  static const PHOTO = "photo";
  static const RATING = "rating";
  static const VOTES = "votes";
  static const PHONE = "phone";

  String _id = "";
  String _name = "";
  String _car = "";
  String _plate = "";
  String _photo = "";
  String _phone = "";

  double _rating = 0.0;
  int _votes = 0;

  DriverPosition _position = DriverPosition(lat: 0.0, lng: 0.0, heading: 0.0);

  // Getters
  String get id => _id;
  String get name => _name;
  String get car => _car;
  String get plate => _plate;
  String get photo => _photo;
  String get phone => _phone;
  DriverPosition get position => _position;
  double get rating => _rating;
  int get votes => _votes;

  DriverModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>? ?? {};

    _id = data[ID] ?? "";
    _name = data[NAME] ?? "Unknown Driver";
    _car = data[CAR] ?? "Unknown Car";
    _plate = data[PLATE] ?? "N/A";
    _photo = data[PHOTO] ?? "";
    _phone = data[PHONE] ?? "No Phone";

    _rating = (data[RATING] ?? 0).toDouble();
    _votes = (data[VOTES] ?? 0);

    if (data[POSITION] != null) {
      _position = DriverPosition(
        lat: (data[POSITION][LATITUDE] ?? 0.0).toDouble(),
        lng: (data[POSITION][LONGITUDE] ?? 0.0).toDouble(),
        heading: (data[POSITION][HEADING] ?? 0.0).toDouble(),
      );
    }
  }

  LatLng getPosition() {
    return LatLng(_position.lat, _position.lng);
  }
}

class DriverPosition {
  final double lat;
  final double lng;
  final double heading;

  DriverPosition({required this.lat, required this.lng, required this.heading});
}
