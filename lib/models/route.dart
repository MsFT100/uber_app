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
  final int value;

  Distance({required this.text, required this.value});

  Distance.fromMap(Map data)
      : text = data["text"] ?? '', // Default to empty string if null
        value = data["value"] ?? 0; // Default to 0 if null

  Map<String, dynamic> toJson() => {"text": text, "value": value};
}

class TimeNeeded {
  final String text;
  final int value;

  TimeNeeded({required this.text, required this.value});

  TimeNeeded.fromMap(Map data)
      : text = data["text"] ?? '', // Default to empty string if null
        value = data["value"] ?? 0; // Default to 0 if null
}
