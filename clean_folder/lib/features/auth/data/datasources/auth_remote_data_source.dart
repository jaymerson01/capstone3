import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
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

    return UserModel.fromFirestore(docSnapshot);
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

    // Role is strictly 'resident' or 'admin'
    final enforcedRole = (role == 'admin') ? 'admin' : 'resident';

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
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final docRef = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await docRef.get();

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
      await docRef.set(fallbackModel.toMap());
      return fallbackModel;
    }

    return UserModel.fromFirestore(docSnapshot);
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    final docRef = _firestore.collection('users').doc(user.id);
    await docRef.update(user.toMap());

    if (user.displayName != null && user.displayName!.isNotEmpty) {
      await _firebaseAuth.currentUser?.updateDisplayName(user.displayName);
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

    // Soft delete / flag inactive in firestore
    await _firestore.collection('users').doc(user.uid).update({'isActive': false});
    await user.delete();
  }
}
