import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../helpers/constants.dart';
import '../models/route.dart';

class GoogleMapsServices {
  Future<RouteModel> getRouteByCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$GOOGLE_MAPS_API_KEY";

    // ✅ Convert String to Uri
    Uri uri = Uri.parse(url);

    http.Response response = await http.get(uri);
    Map values = jsonDecode(response.body);

    if (values["routes"].isEmpty) {
      throw Exception("No route found!");
    }

    Map routes = values["routes"][0];
    Map legs = values["routes"][0]["legs"][0];

    RouteModel route = RouteModel(
        points: routes["overview_polyline"]["points"],
        distance: Distance.fromMap(legs['distance']),
        timeNeeded: TimeNeeded.fromMap(legs['duration']),
        endAddress: legs['end_address'],
        startAddress: legs['start_address'],
        /// THE FIX: We now pass a List<Fare> as required by the RouteModel constructor.
        // This legacy class isn't used, but this makes the code compile.
        fares: [Fare(value: 0, currency: 'KES', vehicleType: '')]);

    return route;
  }
}
