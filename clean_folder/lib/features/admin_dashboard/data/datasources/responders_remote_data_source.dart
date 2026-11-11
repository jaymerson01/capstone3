import 'package:cloud_firestore/cloud_firestore.dart';

/// A barangay tanod or responder admins can assign to reports.
class Responder {
  const Responder({required this.id, required this.name, this.role});

  final String id;
  final String name;

  /// e.g. "Tanod", "BPAT", "Health worker".
  final String? role;

  String get label => role == null || role!.isEmpty ? name : '$name ($role)';
}

/// The barangay's responders list (admins only, see firestore.rules).
class RespondersRemoteDataSource {
  RespondersRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _responders => _firestore.collection('responders');

  /// Active responders, by name.
  Stream<List<Responder>> streamResponders() {
    return _responders.where('active', isEqualTo: true).snapshots().map((snapshot) {
      final list = [
        for (final doc in snapshot.docs)
          Responder(id: doc.id, name: doc.data()['name'] as String? ?? '', role: doc.data()['role'] as String?),
      ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  Future<Responder> addResponder(String name, {String? role}) async {
    final doc = await _responders.add({
      'name': name.trim(),
      if (role != null && role.trim().isNotEmpty) 'role': role.trim(),
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return Responder(id: doc.id, name: name.trim(), role: role?.trim());
  }

  /// Hides a responder from the list; reports keep the name they were given.
  Future<void> removeResponder(String id) => _responders.doc(id).update({'active': false});
}
