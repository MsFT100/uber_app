import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googlemaps_flutter_webservices/places.dart';

const GOOGLE_MAPS_API_KEY = "AIzaSyC_MPgcB-GAIUYap_caF_lQdB1UqFIEhMg";
const COUNTRY = "country";

FirebaseFirestore firebaseFirestore =
    FirebaseFirestore.instance; // Updated Firestore initialization
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseMessaging fcm =
    FirebaseMessaging.instance; // Updated FirebaseMessaging initialization
GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY);
