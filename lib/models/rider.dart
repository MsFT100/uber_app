import 'package:cloud_firestore/cloud_firestore.dart';

class Rider {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePhoto;

  Rider({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePhoto,
  });

  factory Rider.fromMap(Map<String, dynamic> data) {
    return Rider(
      id: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profilePhoto: data['profilePhoto'],
    );
  }
  
  factory Rider.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Rider(
      id: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profilePhoto: data['profilePhoto'],
    );
  }

  Rider copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePhoto,
  }) {
    return Rider(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}
