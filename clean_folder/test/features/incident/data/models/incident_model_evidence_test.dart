import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/features/incident/data/repositories/incident_repository_impl.dart';

/// Evidence photo/video links are private: they live in
/// incidents/{id}/confidential/contact, never in the public incident doc.
void main() {
  const photo = 'https://res.cloudinary.com/demo/image/upload/evidence.jpg';
  const video = 'https://res.cloudinary.com/demo/video/upload/evidence.mp4';

  IncidentModel report({String? photoUrl, String? videoUrl}) => IncidentModel(
        id: 'inc_1',
        reporterId: 'resident_1',
        description: 'Sunog sa likod ng palengke',
        category: 'Fire',
        status: 'pending',
        timestamp: DateTime(2026, 11, 25, 8),
        latitude: 14.4851,
        longitude: 121.0116,
        photoUrl: photoUrl,
        videoUrl: videoUrl,
        reporterName: 'Juan',
      );

  test('photoUrl and videoUrl are confidential keys', () {
    expect(IncidentModel.confidentialKeys, containsAll(['photoUrl', 'videoUrl']));
  });

  test('the public document never carries evidence links or contact details', () {
    for (final model in [report(photoUrl: photo, videoUrl: video), report()]) {
      final public = model.toFirestore();
      for (final key in IncidentModel.confidentialKeys) {
        expect(public.containsKey(key), isFalse, reason: '$key must not be public');
      }
    }
  });

  test('the confidential document carries the evidence links', () {
    final confidential = report(photoUrl: photo, videoUrl: video).toConfidentialFirestore();
    expect(confidential['photoUrl'], photo);
    expect(confidential['videoUrl'], video);
    expect(confidential['reporterId'], 'resident_1');
  });

  test('missing or empty evidence is left out of the confidential document', () {
    expect(report().toConfidentialFirestore().containsKey('photoUrl'), isFalse);
    expect(report().toConfidentialFirestore().containsKey('videoUrl'), isFalse);
    final empty = report(photoUrl: '', videoUrl: '').toConfidentialFirestore();
    expect(empty.containsKey('photoUrl'), isFalse);
    expect(empty.containsKey('videoUrl'), isFalse);
  });

  test('local file paths from a failed upload stay out of Firestore', () {
    final local = report(photoUrl: 'file:///data/user/0/app/cache/photo.jpg', videoUrl: '/tmp/clip.mp4');
    final confidential = local.toConfidentialFirestore();
    expect(confidential.containsKey('photoUrl'), isFalse);
    expect(confidential.containsKey('videoUrl'), isFalse);
    expect(local.toFirestore().containsKey('photoUrl'), isFalse);
  });

  test('withConfidential restores the evidence links', () {
    final restored = report().withConfidential({'photoUrl': photo, 'videoUrl': video});
    expect(restored.photoUrl, photo);
    expect(restored.videoUrl, video);
    expect(restored.reporterName, 'Juan');
  });

  test('withConfidential prefers the confidential value and falls back to the current one', () {
    final local = report(photoUrl: '/local/photo.jpg', videoUrl: '/local/video.mp4');
    expect(local.withConfidential({'photoUrl': photo}).photoUrl, photo);
    expect(local.withConfidential({'photoUrl': photo}).videoUrl, '/local/video.mp4');
    expect(local.withConfidential({'photoUrl': '', 'videoUrl': null}).photoUrl, '/local/photo.jpg');
    expect(local.withConfidential(null).videoUrl, '/local/video.mp4');
  });

  test('without the confidential doc, evidence is simply absent', () {
    final other = report().withConfidential(null);
    expect(other.photoUrl, isNull);
    expect(other.videoUrl, isNull);
  });

  test('the reporter evidence update touches only photoUrl and videoUrl', () {
    expect(IncidentModel.evidenceUpdate(photoUrl: photo), {'photoUrl': photo});
    expect(IncidentModel.evidenceUpdate(videoUrl: video), {'videoUrl': video});
    expect(IncidentModel.evidenceUpdate(), isEmpty);

    final both = IncidentModel.evidenceUpdate(photoUrl: photo, videoUrl: '');
    expect(both.keys, unorderedEquals(IncidentModel.evidenceKeys));
    expect(both['photoUrl'], photo);
    expect(both['videoUrl'], isA<FieldValue>());
  });

  group('legacy migration (admin desk)', () {
    test('moves evidence links from the public doc into the confidential doc', () {
      final move = IncidentRepositoryImpl.legacyConfidentialMove({
        'reporterId': 'resident_1',
        'category': 'Fire',
        'photoUrl': photo,
        'videoUrl': video,
        'reporterName': 'Juan',
      })!;
      expect(move.confidential, {
        'reporterId': 'resident_1',
        'photoUrl': photo,
        'videoUrl': video,
        'reporterName': 'Juan',
      });
      expect(move.removeFromPublic, unorderedEquals(['photoUrl', 'videoUrl', 'reporterName']));
    });

    test('null links are deleted from the public doc but not copied', () {
      final move = IncidentRepositoryImpl.legacyConfidentialMove({
        'reporterId': 'resident_1',
        'photoUrl': null,
        'videoUrl': null,
      })!;
      expect(move.confidential, {'reporterId': 'resident_1'});
      expect(move.removeFromPublic, unorderedEquals(['photoUrl', 'videoUrl']));
    });

    test('a clean public doc needs no migration', () {
      expect(
        IncidentRepositoryImpl.legacyConfidentialMove(report(photoUrl: photo).toFirestore()),
        isNull,
      );
    });
  });
}
