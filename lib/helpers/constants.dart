import 'package:firebase_messaging/firebase_messaging.dart';

const GOOGLE_MAPS_API_KEY = "AIzaSyBX9cRFB3W5L1nedWRatvKJmrhwb-sC4bw";
const COUNTRY = "country";

FirebaseMessaging fcm =
    FirebaseMessaging.instance; // Updated FirebaseMessaging initialization
const user_global_location = null;
String? location_global_address = "Ke";
bool showDriverSheet = false;
String country_global_key = "KE";
int selectedNavIndex = 0;

///Price per kilometer
double price_per_kilometer = 35;
double price_per_kilometer_motorbike = 17;
double base_rate = 200;
double base_rate_motorbike = 30;
double border_radius = 25.0;
