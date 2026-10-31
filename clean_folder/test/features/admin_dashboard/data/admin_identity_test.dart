// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/audit_log_remote_data_source.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/features/incident/data/repositories/incident_repository_impl.dart';

class MockAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserInfo extends Mock implements UserInfo {}

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockCollection extends Mock implements CollectionReference<Map<String, dynamic>> {}

class MockDoc extends Mock implements DocumentReference<Map<String, dynamic>> {}

class MockSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

/// A signed-in admin whose login has [email] and [displayName], with
/// [profile] as their `users` document.
(MockAuth, MockFirestore) admin({
  String? email,
  String? displayName,
  String? providerEmail,
  Map<String, dynamic>? profile,
}) {
  final auth = MockAuth();
  final user = MockUser();
  final info = MockUserInfo();
  when(() => auth.currentUser).thenReturn(user);
  when(() => user.uid).thenReturn('admin_1');
  when(() => user.email).thenReturn(email);
  when(() => user.displayName).thenReturn(displayName);
  when(() => info.email).thenReturn(providerEmail);
  when(() => user.providerData).thenReturn([info]);

  final firestore = MockFirestore();
  final users = MockCollection();
  final doc = MockDoc();
  final snapshot = MockSnapshot();
  when(() => firestore.collection('users')).thenReturn(users);
  when(() => users.doc('admin_1')).thenReturn(doc);
  when(() => doc.get()).thenAnswer((_) async => snapshot);
  when(() => snapshot.data()).thenReturn(profile);
  return (auth, firestore);
}

IncidentModel report({String? name, String? email}) => IncidentModel(
      id: 'inc_1',
      reporterId: 'resident_1',
      description: 'Usok mula sa bahay',
      category: 'Fire Incident',
      status: 'pending',
      timestamp: DateTime(2026, 10, 24),
      latitude: 14.48,
      longitude: 121.01,
      reporterName: name,
      reporterEmail: email,
    );

void main() {
  group('resolveActingAdmin', () {
    test('uses the login email and the profile name', () async {
      final (auth, firestore) = admin(
        email: 'jaymerson@gmail.com',
        profile: {'displayName': 'Jay Merson', 'email': 'jaymerson@gmail.com', 'role': 'admin'},
      );
      final result = await resolveActingAdmin(auth: auth, firestore: firestore);
      expect(result.name, 'Jay Merson');
      expect(result.email, 'jaymerson@gmail.com');
    });

    test('falls back to the sign-in provider email, then the profile email', () async {
      var (auth, firestore) = admin(providerEmail: 'from.google@gmail.com', profile: {});
      expect((await resolveActingAdmin(auth: auth, firestore: firestore)).email, 'from.google@gmail.com');

      (auth, firestore) = admin(profile: {'email': 'profile@gmail.com', 'fullName': 'Ana Reyes'});
      final result = await resolveActingAdmin(auth: auth, firestore: firestore);
      expect(result.email, 'profile@gmail.com');
      expect(result.name, 'Ana Reyes');
    });

    test('never invents an address', () async {
      final (auth, firestore) = admin(profile: null);
      final result = await resolveActingAdmin(auth: auth, firestore: firestore);
      expect(result.email, isNot(contains('@resq.gov')));
      expect(result.email, 'uid admin_1');
    });

    test('reports a missing login plainly', () async {
      final auth = MockAuth();
      when(() => auth.currentUser).thenReturn(null);
      when(() => auth.authStateChanges()).thenAnswer((_) => Stream.value(null));
      final result = await resolveActingAdmin(auth: auth, firestore: MockFirestore());
      expect(result.name, 'Unknown admin');
      expect(result.email, 'not signed in');
    });
  });

  group('fillReporterFromProfile', () {
    const profile = {'displayName': 'Juan Dela Cruz', 'email': 'juan@gmail.com'};

    test('fills a missing name and email from the reporter profile', () {
      final filled = IncidentRepositoryImpl.fillReporterFromProfile(report(), profile);
      expect(filled.reporterName, 'Juan Dela Cruz');
      expect(filled.reporterEmail, 'juan@gmail.com');
    });

    test('keeps what the report already has', () {
      final filled = IncidentRepositoryImpl.fillReporterFromProfile(
        report(name: 'Juan D.', email: 'juan.d@gmail.com'),
        profile,
      );
      expect(filled.reporterName, 'Juan D.');
      expect(filled.reporterEmail, 'juan.d@gmail.com');
    });

    test('leaves the report alone without a profile', () {
      final original = report();
      expect(IncidentRepositoryImpl.fillReporterFromProfile(original, null), same(original));
    });
  });
}
