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

  String _id = ""; // Initialize with a default empty value
  String _name = ""; // Initialize with a default empty value
  String _car = ""; // Initialize with a default empty value
  String _plate = ""; // Initialize with a default empty value
  String _photo = ""; // Initialize with a default empty value
  String _phone = ""; // Initialize with a default empty value

  double _rating = 0.0; // Initialize with a default value
  int _votes = 0; // Initialize with a default value

  DriverPosition _position = DriverPosition(
      lat: 0.0, lng: 0.0, heading: 0.0); // Initialize with default position

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
    // Ensure that snapshot data is a Map<String, dynamic>
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    _name = data[NAME];
    _id = data[ID];
    _car = data[CAR];
    _plate = data[PLATE];
    _photo = data[PHOTO];
    _phone = data[PHONE];

    _rating = data[RATING];
    _votes = data[VOTES];
    _position = DriverPosition(
        lat: data[POSITION][LATITUDE],
        lng: data[POSITION][LONGITUDE],
        heading: data[POSITION][HEADING]);
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
