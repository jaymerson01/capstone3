import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// A resident's request to be verified, with a photo of their ID.
class VerificationRequest {
  const VerificationRequest({
    required this.uid,
    required this.status,
    this.name,
    this.email,
    this.idType,
    this.image,
    this.reason,
    this.submittedAt,
  });

  final String uid;

  /// 'pending' or 'rejected' (approved requests are deleted).
  final String status;
  final String? name;
  final String? email;

  /// 'government_id' or 'valid_id' (another valid ID).
  final String? idType;

  /// The ID photo (JPEG); gone once the request is reviewed.
  final Uint8List? image;

  /// Why it was rejected.
  final String? reason;
  final DateTime? submittedAt;

  bool get isPending => status == 'pending';

  factory VerificationRequest.fromMap(String uid, Map<String, dynamic> data) {
    final encoded = data['image'] as String?;
    return VerificationRequest(
      uid: uid,
      status: data['status'] as String? ?? 'pending',
      name: data['name'] as String?,
      email: data['email'] as String?,
      idType: data['idType'] as String?,
      image: encoded == null ? null : base64Decode(encoded),
      reason: data['reason'] as String?,
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Residents send an ID photo; admins approve (the resident becomes a
/// Verified Resident) or reject it. Photos live in the request document,
/// readable only by that resident and admins, and are deleted once reviewed.
class VerificationRepository {
  VerificationRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Largest photo accepted (Firestore documents hold up to 1 MiB).
  static const int maxImageBytes = 650 * 1024;

  CollectionReference<Map<String, dynamic>> get _requests => _firestore.collection('verification_requests');

  Stream<VerificationRequest?> watchMine(String uid) => _requests
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? VerificationRequest.fromMap(doc.id, doc.data()!) : null);

  Future<void> submit({
    required String uid,
    required String name,
    required String email,
    required String idType,
    required Uint8List image,
  }) {
    if (image.length > maxImageBytes) throw ArgumentError('image too large');
    return _requests.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'idType': idType,
      'image': base64Encode(image),
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Requests waiting for an admin, by resident uid.
  Stream<Map<String, VerificationRequest>> watchPending() => _requests
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) => {for (final doc in snapshot.docs) doc.id: VerificationRequest.fromMap(doc.id, doc.data())});

  /// Verifies the resident and deletes the request with its photo.
  Future<void> approve(String uid) {
    final batch = _firestore.batch()
      ..update(_firestore.collection('users').doc(uid), {'isVerified': true})
      ..delete(_requests.doc(uid));
    return batch.commit();
  }

  /// Tells the resident why, and deletes the photo.
  Future<void> reject(String uid, String reason) => _requests.doc(uid).update({
        'status': 'rejected',
        'reason': reason.trim(),
        'image': FieldValue.delete(),
        'reviewedAt': FieldValue.serverTimestamp(),
      });
}
