import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notegym/models/gym.dart';

class GymService {
  GymService._();

  static final _gymsRef = FirebaseFirestore.instance.collection('gyms');

  static Future<List<Gym>> getAllGyms() async {
    final snapshot = await _gymsRef.orderBy('name').get();
    return snapshot.docs
        .map((doc) => Gym.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  static Future<Gym?> getGymById(String gymId) async {
    final doc = await _gymsRef.doc(gymId).get();
    if (!doc.exists) return null;
    return Gym.fromFirestore(doc.id, doc.data()!);
  }

  static Future<Gym?> getGymBySlug(String slug) async {
    final snapshot = await _gymsRef.where('slug', isEqualTo: slug).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Gym.fromFirestore(doc.id, doc.data());
  }

  static Future<String> createGym({
    required String name,
    required String slug,
    String? address,
    required String createdBy,
  }) async {
    final doc = await _gymsRef.add({
      'name': name,
      'slug': slug,
      'address': address ?? '',
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}
