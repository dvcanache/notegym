import 'package:cloud_firestore/cloud_firestore.dart';

class Gym {
  final String id;
  final String name;
  final String slug;
  final String? address;
  final String createdBy;
  final DateTime createdAt;

  Gym({
    required this.id,
    required this.name,
    required this.slug,
    this.address,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'address': address,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Gym.fromJson(Map<String, dynamic> json) => Gym(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        address: json['address'] as String?,
        createdBy: json['createdBy'] as String,
        createdAt: json['createdAt'] is String
            ? DateTime.parse(json['createdAt'] as String)
            : (json['createdAt'] as Timestamp).toDate(),
      );

  factory Gym.fromFirestore(String docId, Map<String, dynamic> data) => Gym(
        id: docId,
        name: data['name'] as String,
        slug: data['slug'] as String,
        address: data['address'] as String?,
        createdBy: data['createdBy'] as String,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
}
