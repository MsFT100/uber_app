class RouteModel {
  final String points;
  final Distance distance;
  final TimeNeeded timeNeeded;
  final List<Fare> fares;
  final String startAddress;
  final String endAddress;

  RouteModel({
    required this.points,
    required this.distance,
    required this.timeNeeded,
    required this.startAddress,
    required this.endAddress,
    required this.fares,
  });
}

class Fare {
  // THE FIX: Added the vehicleType property
  final String vehicleType;
  final double value;
  final String currency;

  Fare({required this.vehicleType, required this.value, required this.currency});

  // THE FIX: Corrected the fromMap factory to match the API response
  Fare.fromMap(Map<String, dynamic> data)
      : vehicleType = data['type'] ?? 'unknown', // Reads 'type' from the API
        value = double.tryParse(data['fare']?.toString() ?? '0.0') ?? 0.0, // Reads 'fare' from the API
        currency = data['currency'] ?? 'KES'; // Assumes 'KES' if not provided

  // A getter for a formatted string representation
  String get text => '$currency ${value.toStringAsFixed(0)}';
}

class Distance {
  final String text;
  final int value; // Distance in meters

  Distance({required this.text, required this.value});

  Distance.fromMap(Map data)
      : text = data["text"] ?? '',
        value = data["value"] ?? 0;

  Map<String, dynamic> toJson() => {
    "text": text,
    "value": value,
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
