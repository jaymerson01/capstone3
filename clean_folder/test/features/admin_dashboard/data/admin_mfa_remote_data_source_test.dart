// ignore_for_file: subtype_of_sealed_class
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/admin_accounts_remote_data_source.dart';

class MockAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockCollection extends Mock implements CollectionReference<Map<String, dynamic>> {}

class MockDoc extends Mock implements DocumentReference<Map<String, dynamic>> {}

class MockBatch extends Mock implements WriteBatch {}

void main() {
  late MockAuth auth;
  late MockFirestore firestore;
  late List<http.Request> requests;

  setUp(() {
    auth = MockAuth();
    firestore = MockFirestore();
    requests = [];
    final user = MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken()).thenAnswer((_) async => 'id-token');
  });

  AdminAccountsRemoteDataSourceImpl source(http.Response Function(http.Request) answer) {
    return AdminAccountsRemoteDataSourceImpl(
      firestore: firestore,
      auth: auth,
      projectId: 'demo-resq',
      client: MockClient((request) async {
        requests.add(request);
        return answer(request);
      }),
    );
  }

  http.Response result(Map<String, dynamic> value) => http.Response(jsonEncode({'result': value}), 200);

  http.Response error(int code, String status, [String? reason]) => http.Response(
        jsonEncode({
          'error': {
            'status': status,
            'message': 'server message',
            'details': ?(reason == null ? null : {'reason': reason}),
          },
        }),
        code,
      );

  Future<AdminMfaFailure?> failureOf(Future<void> call) async {
    try {
      await call;
      return null;
    } on AdminMfaException catch (e) {
      return e.failure;
    }
  }

  test('calls adminMfa as a callable function with the ID token', () async {
    final data = source((_) => result({'ok': true}));
    await data.verifyMfaCode('123 456');

    final request = requests.single;
    expect(request.method, 'POST');
    expect(request.url.toString(), 'https://asia-southeast1-demo-resq.cloudfunctions.net/adminMfa');
    expect(request.headers['Authorization'], 'Bearer id-token');
    expect(jsonDecode(request.body), {
      'data': {'action': 'verify', 'code': '123456'},
    });
  });

  test('reads status and the setup key from the result', () async {
    expect(await source((_) => result({'enrolled': true})).mfaStatus(), isTrue);
    expect(await source((_) => result({'enrolled': false})).mfaStatus(), isFalse);
    expect(await source((_) => result({'secret': 'ABCDEF'})).beginMfaSetup(), 'ABCDEF');
    expect(jsonDecode(requests.last.body), {
      'data': {'action': 'beginSetup'},
    });
  });

  test('turns server errors into typed failures', () async {
    expect(
      await failureOf(source((_) => error(403, 'PERMISSION_DENIED', 'wrong-code')).verifyMfaCode('000000')),
      AdminMfaFailure.wrongCode,
    );
    expect(
      await failureOf(source((_) => error(403, 'PERMISSION_DENIED', 'not-admin')).verifyMfaCode('000000')),
      AdminMfaFailure.notAllowed,
    );
    expect(
      await failureOf(source((_) => error(429, 'RESOURCE_EXHAUSTED', 'locked-out')).verifyMfaCode('000000')),
      AdminMfaFailure.lockedOut,
    );
    expect(
      await failureOf(source((_) => error(400, 'FAILED_PRECONDITION', 'already-enrolled')).beginMfaSetup()),
      AdminMfaFailure.setupState,
    );
    expect(
      await failureOf(source((_) => error(500, 'INTERNAL')).verifyMfaCode('000000')),
      AdminMfaFailure.other,
    );
  });

  test('reports a function that is not deployed, or no connection, as unavailable', () async {
    expect(
      await failureOf(source((_) => http.Response('<html>404 Page not found</html>', 404)).mfaStatus()),
      AdminMfaFailure.unavailable,
    );
    expect(
      await failureOf(source((_) => throw http.ClientException('XMLHttpRequest error.')).mfaStatus()),
      AdminMfaFailure.unavailable,
    );
  });

  test('resetMfa removes the key and the verified session in one batch', () async {
    final batch = MockBatch();
    final refs = <String, MockDoc>{};
    when(() => firestore.batch()).thenReturn(batch);
    when(() => firestore.collection(any())).thenAnswer((call) {
      final name = call.positionalArguments.first as String;
      final collection = MockCollection();
      when(() => collection.doc(any())).thenAnswer((_) => refs[name] = MockDoc());
      return collection;
    });
    when(() => batch.commit()).thenAnswer((_) async {});

    await source((_) => result({})).resetMfa('admin_1');

    verify(() => batch.update(refs['users']!, {'mfaEnabledAt': FieldValue.delete()})).called(1);
    verify(() => batch.delete(refs['admin_mfa']!)).called(1);
    verify(() => batch.delete(refs['admin_sessions']!)).called(1);
    verify(() => batch.commit()).called(1);
    expect(requests, isEmpty, reason: 'no function call needed');
  });
}
