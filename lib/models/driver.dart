import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverModel {
  static const ID = "id";
  static const NAME = "name";
  static const EMAIL = "email";
  static const PHONE = "phone";
  static const VOTES = "votes";
  static const TRIPS = "trips";
  static const RATING = "rating";
  static const TOKEN = "token";
  static const PHOTO = "photo";
  static const BRAND = "brand";
  static const MODEL = "model";
  static const FUEL_TYPE = "fuelType";
  static const LICENSE_PLATE = "licensePlate";
  static const HAS_VEHICLE = "hasVehicle";
  static const LATITUDE = "latitude";
  static const LONGITUDE = "longitude";
  static const HEADING = "heading";
  static const POSITION = "position";

  late final String _id;
  late final String _name;
  late final String _email;
  late final String _phone;
  late final String _token;
  late final String _photo;
  late final String _brand;
  late final String _model;
  late final String _fuelType;
  late final String _licensePlate;
  late final bool _hasVehicle;

  late final int _votes;
  late final int _trips;
  late final double _rating;

  DriverPosition _position = DriverPosition(lat: 0.0, lng: 0.0, heading: 0.0);

  //  getters
  String get name => _name;
  String get email => _email;
  String get id => _id;
  String get phone => _phone;
  int get votes => _votes;
  int get trips => _trips;
  double get rating => _rating;
  String get token => _token;
  String get photo => _photo;
  String get brand => _brand;
  String get model => _model;
  String get licensePlate => _licensePlate;
  String get fuelType => _fuelType;
  bool get hasVehicle => _hasVehicle;
  DriverPosition get position => _position;
  DriverModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>? ?? {};

    _name = data[NAME] ?? ''; // Default to an empty string
    _email = data[EMAIL] ?? '';
    _id = data[ID] ?? '';
    _token = data[TOKEN] ?? '';

    _hasVehicle = data[HAS_VEHICLE] ?? false;
    _photo = data[PHOTO] ?? '';
    _fuelType = data[FUEL_TYPE] ?? '';
    _brand = data[BRAND] ?? '';
    _model = data[MODEL] ?? '';
    _licensePlate = data[LICENSE_PLATE] ?? '';
    _phone = data[PHONE] ?? '';
    _votes = data[VOTES] ?? 0; // Default to 0
    _trips = data[TRIPS] ?? 0;
    _rating = (data[RATING] ?? 0).toDouble();

    //_rating = (data[RATING] ?? 0).toDouble();
    //_votes = (data[VOTES] ?? 0);

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
