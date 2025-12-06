import 'dart:convert';

class Vehicle {
  final String? model;
  final String? color;
  final String? numberPlate;

  Vehicle({this.model, this.color, this.numberPlate});

  factory Vehicle.fromMap(Map<String, dynamic> data) {
    return Vehicle(
      model: data['model'] as String?,
      color: data['color'] as String?,
      numberPlate: data['numberPlate'] as String?,
    );
  }
}

class Driver {
  final String? id;
  final String name;
  final String? phone;
  final String? profilePhotoUrl;
  final double? rating;
  final Vehicle? vehicle;

  Driver({
    this.id,
    required this.name,
    required this.phone,
    this.profilePhotoUrl,
    this.rating,
    this.vehicle,
  });

  factory Driver.fromMap(Map<String, dynamic> data) {
    // --- ROBUST VEHICLE PARSING ---
    // The 'vehicle' data from a push notification might be a JSON string
    // or a map. This handles both cases to prevent a crash.
    Map<String, dynamic>? vehicleData;
    if (data['vehicle'] is String) {
      vehicleData = jsonDecode(data['vehicle']) as Map<String, dynamic>?;
    } else if (data['vehicle'] is Map) {
      vehicleData = data['vehicle'] as Map<String, dynamic>?;
    }
    // --- END OF REFACTOR ---
    return Driver(
      id: data['uid'],
      name: data['name'] ?? 'N/A',
      phone: data['phone']?.toString(),
      profilePhotoUrl: data['profilePhotoUrl'],
      rating: double.tryParse(data['rating']?.toString() ?? ''),
      vehicle: vehicleData != null ? Vehicle.fromMap(vehicleData) : null,
    );
  }
}
