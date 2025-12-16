import 'dart:convert';

class SavedAddress {
  final String label;
  final String address;

  SavedAddress({required this.label, required this.address});

  // Factory constructor to create a SavedAddress from a map
  factory SavedAddress.fromMap(Map<String, dynamic> map) {
    return SavedAddress(
      label: map['label'] as String,
      address: map['address'] as String,
    );
  }

  // Method to convert a SavedAddress instance to a map
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'address': address,
    };
  }

  // Helper to convert from a JSON string
  factory SavedAddress.fromJson(String source) =>
      SavedAddress.fromMap(json.decode(source) as Map<String, dynamic>);

  // Helper to convert to a JSON string
  String toJson() => json.encode(toMap());
}
