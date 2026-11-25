import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:community_safety_app/features/auth/data/models/user_model.dart';

/// Why a two-step verification call to the server failed.
enum AdminMfaFailure {
  /// The code was wrong, expired or already used.
  wrongCode,

  /// Too many wrong codes: the server refuses codes for 15 minutes.
  lockedOut,

  /// No authenticator is linked yet, or the setup was replaced (verify), or
  /// one is already linked (setup).
  setupState,

  /// The account isn't an active admin.
  notAllowed,

  /// The function isn't deployed yet, or the server can't be reached.
  unavailable,

  /// Anything else (signed out, server error).
  other,
}

/// A two-step verification call to the `adminMfa` Cloud Function failed.
class AdminMfaException implements Exception {
  const AdminMfaException(this.failure, [this.message = '']);

  final AdminMfaFailure failure;
  final String message;

  @override
  String toString() => 'AdminMfaException(${failure.name}): $message';
}

/// Admin accounts: super admins creating other admins, and each admin's
/// two-step sign-in. The authenticator key never reaches the app after setup:
/// the `adminMfa` Cloud Function checks codes and opens the server-side admin
/// session (`admin_sessions/{uid}`) that the database rules require.
abstract class AdminAccountsRemoteDataSource {
  /// Whether the signed-in admin has linked an authenticator app.
  Future<bool> mfaStatus();

  /// Starts linking an authenticator app: returns the new key to show as a QR
  /// code. Throws [AdminMfaException] ([AdminMfaFailure.setupState]) if one is
  /// already linked.
  Future<String> beginMfaSetup();

  /// Checks [code] on the server. Returns normally when it is right (and, the
  /// first time, finishes linking the app); otherwise throws
  /// [AdminMfaException].
  Future<void> verifyMfaCode(String code);

  /// Unlinks a lost authenticator and ends that admin's verified session
  /// (super admins only); the admin links a new one at their next sign-in.
  Future<void> resetMfa(String uid);

  /// Creates a staff account ([role] 'admin' or 'responder', with the
  /// responder's [department]) and emails them a link to choose their
  /// password. Returns the new account's uid.
  Future<String> createStaffAccount({
    required String email,
    required String displayName,
    String role = 'admin',
    String? department,
  });
}

class AdminAccountsRemoteDataSourceImpl implements AdminAccountsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final http.Client client;

  /// Defaults to the Firebase project the app runs against.
  final String? projectId;

  /// Written only by the `adminMfa` Cloud Function (see functions/index.js).
  static const String mfaCollection = 'admin_mfa';
  static const String sessionsCollection = 'admin_sessions';

  /// Must match REGION in functions/index.js.
  static const String _functionsRegion = 'asia-southeast1';
  static const String _functionName = 'adminMfa';

  AdminAccountsRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
    http.Client? client,
    this.projectId,
  }) : client = client ?? http.Client();

  Uri _functionUri() {
    final project = projectId ?? Firebase.app().options.projectId;
    return Uri.parse('https://$_functionsRegion-$project.cloudfunctions.net/$_functionName');
  }

  /// Calls `adminMfa` with the callable HTTPS protocol (Bearer ID token,
  /// body `{data: ...}`, answer in `result` or `error`).
  Future<Map<String, dynamic>> _call(Map<String, dynamic> data) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const AdminMfaException(AdminMfaFailure.other, 'Please sign in again.');
    }

    final http.Response response;
    try {
      final idToken = await user.getIdToken();
      response = await client
          .post(
            _functionUri(),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode({'data': data}),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const AdminMfaException(AdminMfaFailure.unavailable, 'The server took too long to answer.');
    } on FirebaseAuthException catch (e) {
      throw AdminMfaException(AdminMfaFailure.other, e.message ?? e.code);
    } catch (e) {
      // No connection, or (on the web) the function isn't deployed, so the
      // browser blocks the answer.
      throw AdminMfaException(AdminMfaFailure.unavailable, '$e');
    }

    dynamic decoded;
    try {
      decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } on FormatException {
      decoded = null;
    }

    if (response.statusCode == 200 && decoded is Map && decoded['result'] is Map) {
      return Map<String, dynamic>.from(decoded['result'] as Map);
    }

    final error = decoded is Map && decoded['error'] is Map ? decoded['error'] as Map : null;
    if (error == null) {
      // A 404 page (not deployed yet) or a proxy error: not a callable answer.
      throw AdminMfaException(AdminMfaFailure.unavailable, 'Server answered with status ${response.statusCode}.');
    }
    final status = error['status'] as String? ?? '';
    final message = error['message'] as String? ?? '';
    final details = error['details'];
    final reason = details is Map ? details['reason'] as String? : null;
    throw AdminMfaException(switch (status) {
      'PERMISSION_DENIED' when reason == 'wrong-code' => AdminMfaFailure.wrongCode,
      'PERMISSION_DENIED' => AdminMfaFailure.notAllowed,
      'RESOURCE_EXHAUSTED' => AdminMfaFailure.lockedOut,
      'FAILED_PRECONDITION' => AdminMfaFailure.setupState,
      'NOT_FOUND' || 'UNAVAILABLE' => AdminMfaFailure.unavailable,
      _ => AdminMfaFailure.other,
    }, message);
  }

  @override
  Future<bool> mfaStatus() async {
    final result = await _call({'action': 'status'});
    return result['enrolled'] == true;
  }

  @override
  Future<String> beginMfaSetup() async {
    final result = await _call({'action': 'beginSetup'});
    final secret = result['secret'];
    if (secret is! String || secret.isEmpty) {
      throw const AdminMfaException(AdminMfaFailure.other, 'The server sent no key.');
    }
    return secret;
  }

  @override
  Future<void> verifyMfaCode(String code) async {
    final result = await _call({'action': 'verify', 'code': code.replaceAll(RegExp(r'\s'), '')});
    if (result['ok'] != true) {
      throw const AdminMfaException(AdminMfaFailure.other, 'The server did not confirm the code.');
    }
  }

  @override
  Future<void> resetMfa(String uid) async {
    // One batch: the rules check each write against the state before it, so
    // a super admin resetting their own sign-in isn't locked out halfway.
    final batch = firestore.batch()
      ..update(firestore.collection('users').doc(uid), {'mfaEnabledAt': FieldValue.delete()})
      ..delete(firestore.collection(mfaCollection).doc(uid))
      ..delete(firestore.collection(sessionsCollection).doc(uid));
    await batch.commit();
  }

  @override
  Future<String> createStaffAccount({
    required String email,
    required String displayName,
    String role = 'admin',
    String? department,
  }) async {
    // Signing up through the main app would sign the super admin out, so a
    // second, throwaway app instance does it.
    final secondary = await Firebase.initializeApp(
      name: 'create-admin-${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondary);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: _throwawayPassword(),
      );
      final uid = credential.user!.uid;

      // The new account files its own profile as a resident (the only kind
      // the rules let an account create for itself); the super admin then
      // promotes it.
      await FirebaseFirestore.instanceFor(app: secondary).collection('users').doc(uid).set(
            UserModel(id: uid, email: email, displayName: displayName, createdAt: DateTime.now()).toMap(),
          );
      await secondaryAuth.signOut();

      await firestore.collection('users').doc(uid).update({
        'role': role,
        'isVerified': true,
        'department': ?department,
      });
      await auth.sendPasswordResetEmail(email: email);
      return uid;
    } finally {
      await secondary.delete();
    }
  }

  /// Never shown or stored: the new admin replaces it from the emailed link.
  static String _throwawayPassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#%';
    final rng = Random.secure();
    return List.generate(32, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
