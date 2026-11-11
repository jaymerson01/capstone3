import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_safety_app/core/utils/departments.dart';

/// A responder account (tanod, BFP, PNP, health/rescue) admins can assign.
class Responder {
  const Responder({required this.id, required this.name, this.department});

  final String id;
  final String name;
  final Department? department;

  String get label => department == null ? name : '$name · ${department!.label}';
}

/// The barangay's responder accounts: users with the 'responder' role,
/// created by a super admin in User Management.
class RespondersRemoteDataSource {
  RespondersRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Active responders, by department then name.
  Stream<List<Responder>> streamResponders() {
    return _firestore.collection('users').where('role', isEqualTo: 'responder').snapshots().map((snapshot) {
      final list = [
        for (final doc in snapshot.docs)
          if (doc.data()['isActive'] != false)
            Responder(
              id: doc.id,
              name: (doc.data()['displayName'] ?? doc.data()['fullName'] ?? doc.data()['email'] ?? '') as String,
              department: Department.fromId(doc.data()['department'] as String?),
            ),
      ]..sort((a, b) {
          final byDept = (a.department?.index ?? 99).compareTo(b.department?.index ?? 99);
          return byDept != 0 ? byDept : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      return list;
    });
  }
}
