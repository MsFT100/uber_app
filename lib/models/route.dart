class RouteModel {
  final String points;
  final Distance distance;
  final TimeNeeded timeNeeded;
  final String startAddress;
  final String endAddress;

  RouteModel({
    required this.points,
    required this.distance,
    required this.timeNeeded,
    required this.startAddress,
    required this.endAddress,
  });
}

class Distance {
  final String text;
  final int value; // Distance in meters

  Distance({required this.text, required this.value});

  Distance.fromMap(Map data)
      : text = data["text"] ?? '',
        value = data["value"] ?? 0;

  // ✅ Automatically calculate and round ride price
  double get ridePrice {
    const double pricePerKm = 35;
    double price =
        (value / 1000.0) * pricePerKm; // Convert meters to km and multiply
    return double.parse(
        price.toStringAsFixed(2)); // ✅ Round to 2 decimal places
  }

  Map<String, dynamic> toJson() => {
        "text": text,
        "value": ridePrice,
        //"ridePrice": ridePrice, // ✅ Include price in JSON
      };
}

class TimeNeeded {
  final String text;
  final int value;

  TimeNeeded({required this.text, required this.value});

  TimeNeeded.fromMap(Map data)
      : text = data["text"] ?? '', // Default to empty string if null
        value = data["value"] ?? 0; // Default to 0 if null
}
