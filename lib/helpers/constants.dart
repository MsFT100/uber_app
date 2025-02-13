import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googlemaps_flutter_webservices/places.dart';

//const GOOGLE_MAPS_API_KEY = "AIzaSyBqD2lxHfrvXS6DszBaG1w-dHAXnArbbPE";
const GOOGLE_MAPS_API_KEY = "AIzaSyAGDlcfxXtt2rmk_GrytWTVRGMHngzdHYM";
const COUNTRY = "country";

FirebaseMessaging fcm =
    FirebaseMessaging.instance; // Updated FirebaseMessaging initialization
GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY);
const user_global_location = null;
String? location_global_address = "Ke";

String country_global_key = "Kenya";
int selectedNavIndex = 0;
