import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:community_safety_app/features/auth/data/models/user_model.dart';

/// Admin accounts: super admins creating other admins, and the authenticator
/// keys behind each admin's two-step sign-in.
abstract class AdminAccountsRemoteDataSource {
  /// The admin's authenticator key, or null before they have linked an app.
  Future<String?> mfaSecret(String uid);

  /// Saves the key once the admin has proved their app shows the right code.
  Future<void> enrollMfa({required String uid, required String email, required String secret});

  /// Unlinks a lost authenticator (super admins only); the admin links a new
  /// one at their next sign-in.
  Future<void> resetMfa(String uid);

  /// Creates an admin account and emails the new admin a link to choose
  /// their password. Returns the new account's uid.
  Future<String> createAdmin({required String email, required String displayName});
}

class AdminAccountsRemoteDataSourceImpl implements AdminAccountsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  /// Readable only by the admin it belongs to (see firestore.rules).
  static const String mfaCollection = 'admin_mfa';

  AdminAccountsRemoteDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<String?> mfaSecret(String uid) async {
    final doc = await firestore.collection(mfaCollection).doc(uid).get();
    return doc.data()?['secret'] as String?;
  }

  @override
  Future<void> enrollMfa({required String uid, required String email, required String secret}) async {
    await firestore.collection(mfaCollection).doc(uid).set({
      'secret': secret,
      'email': email,
      'enabledAt': FieldValue.serverTimestamp(),
    });
    // Lets User Management show who has two-step sign-in on, without the key.
    await firestore.collection('users').doc(uid).update({'mfaEnabledAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> resetMfa(String uid) async {
    await firestore.collection(mfaCollection).doc(uid).delete();
    await firestore.collection('users').doc(uid).update({'mfaEnabledAt': FieldValue.delete()});
  }

  @override
  Future<String> createAdmin({required String email, required String displayName}) async {
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

      await firestore.collection('users').doc(uid).update({'role': 'admin', 'isVerified': true});
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
