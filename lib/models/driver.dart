class Driver {
  final String? id;
  final String name;
  final String? profilePhotoUrl;
  final double? rating;
  final String? carModel;
  final String? carColor;
  final String? licensePlate;

  Driver({
    this.id,
    required this.name,
    this.profilePhotoUrl,
    this.rating,
    this.carModel,
    this.carColor,
    this.licensePlate,
  });

  factory Driver.fromMap(Map<String, dynamic> data) {
    final vehicle = data['vehicle'] as Map<String, dynamic>?;
    return Driver(
      id: data['uid'],
      name: data['name'] ?? 'N/A',
      profilePhotoUrl: data['profilePhotoUrl'],
      rating: (data['rating'] as num?)?.toDouble(),
      carModel: vehicle?['model'],
      carColor: vehicle?['color'],
      licensePlate: vehicle?['numberPlate'],
    );
  }
}
