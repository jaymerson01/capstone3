import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/verification/data/verification_repository.dart';
import 'package:community_safety_app/features/verification/presentation/verification_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class MockVerificationRepository extends Mock implements VerificationRepository {}

class MockImagePicker extends Mock implements ImagePicker {}

const _resident = UserEntity(id: 'r1', email: 'ana@gmail.com', displayName: 'Ana Reyes');

void main() {
  late MockVerificationRepository repository;
  late MockImagePicker picker;

  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(Uint8List(0));
  });
  setUp(() {
    repository = MockVerificationRepository();
    picker = MockImagePicker();
  });

  Future<void> pumpPage(WidgetTester tester, {VerificationRequest? request, UserEntity user = _resident}) async {
    when(() => repository.watchMine('r1')).thenAnswer((_) => Stream.value(request));
    await tester.binding.setSurfaceSize(const Size(500, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fil'),
      home: VerificationPage(user: user, repository: repository, picker: picker),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('a resident sends a government ID photo for review', (tester) async {
    // A real 1x1 PNG, so the preview can show it.
    final photo = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=');
    when(() => picker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          imageQuality: any(named: 'imageQuality'),
        )).thenAnswer((_) async => XFile.fromData(photo, name: 'id.jpg'));
    when(() => repository.submit(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          email: any(named: 'email'),
          idType: any(named: 'idType'),
          image: any(named: 'image'),
        )).thenAnswer((_) async {});
    await pumpPage(tester);

    expect(find.text('Government ID'), findsOneWidget);
    expect(find.text('Iba pang valid ID'), findsOneWidget);
    expect(find.textContaining('Patunay ng address'), findsNothing);

    await tester.tap(find.text('Pumili ng litrato'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('verify-submit')));
    await tester.pumpAndSettle();

    verify(() => repository.submit(
          uid: 'r1',
          name: 'Ana Reyes',
          email: 'ana@gmail.com',
          idType: 'government_id',
          image: photo,
        )).called(1);
  });

  testWidgets('shows the review status instead of the form', (tester) async {
    await pumpPage(tester, request: const VerificationRequest(uid: 'r1', status: 'pending'));
    expect(find.text('Sinusuri pa ng barangay ang ID mo.'), findsOneWidget);
    expect(find.byKey(const Key('verify-submit')), findsNothing);
  });

  testWidgets('a rejected resident sees why and can send another', (tester) async {
    await pumpPage(tester, request: const VerificationRequest(uid: 'r1', status: 'rejected', reason: 'Malabo ang litrato'));
    expect(find.textContaining('Malabo ang litrato'), findsOneWidget);
    expect(find.byKey(const Key('verify-submit')), findsOneWidget);
  });
}
