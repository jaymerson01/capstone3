import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? fullName,
    String role = 'resident',
  });
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateUserProfile(UserModel user);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No authenticated user record returned.',
      );
    }

    final docRef = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      // Auto-initialize profile document if first time
      // Role defaults to 'resident'. Admin role is assigned via Firestore only.
      final newModel = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? email.trim(),
        displayName: firebaseUser.displayName ?? 'Resident Citizen',
        role: 'resident',
        isVerified: firebaseUser.emailVerified,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await docRef.set(newModel.toMap());
      return newModel;
    }

    final existingUser = UserModel.fromFirestore(docSnapshot);
    await _ensureAccountActive(existingUser);
    return existingUser;
  }

  /// Signs the user out and throws if an admin has suspended this account.
  Future<void> _ensureAccountActive(UserModel user) async {
    if (user.isActive) return;
    await signOut();
    throw FirebaseAuthException(
      code: 'user-disabled',
      message:
          'This account has been suspended by the Barangay Moonwalk admin. Please contact the barangay help desk.',
    );
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? fullName,
    String role = 'resident',
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Failed to create user account.',
      );
    }

    if (fullName != null && fullName.isNotEmpty) {
      await firebaseUser.updateDisplayName(fullName);
    }

    // Self-registration always creates a resident. Admin accounts are
    // promoted by an existing admin (Firestore rules block anything else).
    const enforcedRole = 'resident';

    final newUser = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? email.trim(),
      displayName: fullName ?? 'Resident Citizen',
      role: enforcedRole,
      isVerified: false,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());

    return newUser;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-canceled',
        message: 'Google Sign-In was cancelled by the user.',
      );
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    final User? firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No authenticated user record returned from Google.',
      );
    }

    final docRef = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      final newModel = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? (googleUser.displayName ?? 'Resident Citizen'),
        photoUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
        role: 'resident',
        isVerified: true,
        isActive: true,
        createdAt: DateTime.now(),
      );
      await docRef.set(newModel.toMap());
      return newModel;
    } else {
      final existingUser = UserModel.fromFirestore(docSnapshot);
      await _ensureAccountActive(existingUser);
      return existingUser;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    UserModel? onlineUser;
    try {
      final docRef = _firestore.collection('users').doc(firebaseUser.uid);
      final docSnapshot =
          await docRef.get().timeout(const Duration(seconds: 4));

      if (!docSnapshot.exists) {
        // Role defaults to 'resident'. Admin role is assigned via Firestore only.
        final fallbackModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'Resident Citizen',
          role: 'resident',
          isVerified: firebaseUser.emailVerified,
          isActive: true,
          createdAt: DateTime.now(),
        );
        try {
          await docRef
              .set(fallbackModel.toMap())
              .timeout(const Duration(seconds: 2));
        } catch (_) {}
        return fallbackModel;
      }

      onlineUser = UserModel.fromFirestore(docSnapshot);
    } catch (_) {
      // Offline fallback: Use Hive cache or fallback to firebaseUser credentials
      String cachedRole = 'resident';
      try {
        if (Hive.isBoxOpen('auth')) {
          cachedRole = Hive.box('auth').get('userRole', defaultValue: 'resident')
                  as String? ??
              'resident';
        }
      } catch (_) {}

      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'Resident Citizen',
        role: cachedRole,
        isVerified: firebaseUser.emailVerified,
        isActive: true,
        createdAt: DateTime.now(),
      );
    }

    // Suspended while signed in: end the session on next app start.
    final current = onlineUser;
    if (!current.isActive) {
      await signOut();
      return null;
    }
    return current;
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    final docRef = _firestore.collection('users').doc(user.id);
    // Role, suspension, verification and creation date are managed by admins
    // only; never send them from a profile edit.
    final updates = Map<String, dynamic>.from(user.toMap())
      ..remove('role')
      ..remove('isActive')
      ..remove('isVerified')
      ..remove('createdAt');
    await docRef.update(updates);

    if (user.displayName != null && user.displayName!.isNotEmpty) {
      await _firebaseAuth.currentUser?.updateDisplayName(user.displayName);
    }
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      await _firebaseAuth.currentUser?.updatePhotoURL(user.photoUrl);
    }

    return user;
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No logged in user found to change password.',
      );
    }

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    // Right to erasure (RA 10173): remove the profile, then the login.
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }
}
