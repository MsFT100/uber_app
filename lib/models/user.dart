import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const ID = "id";
  static const NAME = "name";
  static const EMAIL = "email";
  static const PHONE = "phone";
  static const VOTES = "votes";
  static const TRIPS = "trips";
  static const RATING = "rating";
  static const TOKEN = "token";
  static const PHOTO = "photo";
  static const FREE_RIDES_REMAINING = "freeRidesRemaining";
  static const FREE_RIDE_AMOUNT_REMAINING = "freeRideAmountRemaining";


  late final String _id;
  late final String _name;
  late final String _email;
  late final String _phone;
  late final String _token;
  late final String _photoURL;

  late final int _votes;
  late final int _trips;
  late final double _rating;

  late int _freeRidesRemaining;
  late double _freeRideAmountRemaining;

  // Setters
  set freeRidesRemaining(int value) {
    _freeRidesRemaining = value;
  }

  set freeRideAmountRemaining(double value) {
    _freeRideAmountRemaining = value;
  }


  // Getters
  String get name => _name;
  String get email => _email;
  String get id => _id;
  String get token => _token;

  String get phone => _phone;
  String get photoURL => _photoURL;
  int get votes => _votes;
  int get trips => _trips;
  double get rating => _rating;


  // free rides remaining
  int get freeRidesRemaining => _freeRidesRemaining;
  double get freeRideAmountRemaining => _freeRideAmountRemaining;

  // Add a setter for photoURL
  set photoURL(String url) {
    _photoURL = url;
  }

  toJson() {
    return {
      "name": _name,
      "email": _email,
      "phone": _phone,
      "trips": _trips,
      "rating": _rating,
      "photoURL": _photoURL,
      FREE_RIDES_REMAINING: _freeRidesRemaining,
      FREE_RIDE_AMOUNT_REMAINING: _freeRideAmountRemaining,
    };
  }

  UserModel({
    required String name,
    required String phoneNumber,
  })  : _name = name,
        _phone = phoneNumber,
        _email = '',
        _id = '',
        _token = '',
        _votes = 0,
        _trips = 0,
        _rating = 0.0;

  // Constructor from snapshot
  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?; // Cast to Map
    _name = data?[NAME] ?? ''; // Default to an empty string
    _email = data?[EMAIL] ?? '';
    _id = data?[ID] ?? '';
    _token = data?[TOKEN] ?? '';
    _photoURL = data?[PHOTO] ?? '';

    _phone = data?[PHONE] ?? '';
    _votes = data?[VOTES] ?? 0; // Default to 0
    _trips = data?[TRIPS] ?? 0;
    _rating = (data?[RATING] ?? 0).toDouble(); // Ensure it's double
    _freeRidesRemaining = data?[FREE_RIDES_REMAINING] ?? 3; // default 2
    _freeRideAmountRemaining = data?[FREE_RIDE_AMOUNT_REMAINING] ?? 0;
  }
}
