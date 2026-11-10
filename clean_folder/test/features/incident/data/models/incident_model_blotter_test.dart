import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';

void main() {
  IncidentModel report({bool isBlotter = false}) => IncidentModel(
        id: 'inc_1',
        reporterId: 'resident_1',
        description: 'Nagnakaw ng bisikleta sa tapat ng tindahan',
        category: 'Theft / Robbery',
        status: 'pending',
        timestamp: DateTime(2026, 10, 24, 9, 30),
        latitude: 14.4851,
        longitude: 121.0116,
        isBlotter: isBlotter,
      );

  test('the blotter flag is written to the public incident document', () {
    expect(report(isBlotter: true).toFirestore()['isBlotter'], isTrue);
    expect(report().toFirestore()['isBlotter'], isFalse);
  });

  test('the blotter flag survives copyWith and withConfidential', () {
    final model = report(isBlotter: true);
    expect(model.copyWith(status: 'in_progress').isBlotter, isTrue);
    expect(model.withConfidential({'reporterName': 'Juan'}).isBlotter, isTrue);
    expect(model.copyWith(isBlotter: false).isBlotter, isFalse);
  });

  test('the blotter flag is kept in the offline Hive cache', () async {
    final dir = await Directory.systemTemp.createTemp('resq_hive_blotter');
    addTearDown(() => dir.delete(recursive: true));
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(IncidentModelAdapter());
    }

    var box = await Hive.openBox<IncidentModel>('incidents_blotter_test');
    await box.put('blotter', report(isBlotter: true));
    await box.put('plain', report());
    await box.close();

    box = await Hive.openBox<IncidentModel>('incidents_blotter_test');
    expect(box.get('blotter')!.isBlotter, isTrue);
    expect(box.get('plain')!.isBlotter, isFalse);
    await box.close();
  });
}
