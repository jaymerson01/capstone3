import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:community_safety_app/core/services/camera_service_impl.dart';

const _photo = [0xFF, 0xD8, 0xFF, 0xE0, 0x52, 0x65, 0x73, 0x51]; // JPEG-ish
const _cloudUrl = 'https://res.cloudinary.com/demo/image/upload/v1/resq_photos/a.jpg';

/// A stand-in for Cloudinary that records what it was sent.
MockClient cloudinary(List<http.Request> sent) => MockClient((request) async {
      sent.add(request);
      return http.Response(jsonEncode({'secure_url': _cloudUrl}), 200);
    });

/// The photo as the picker would hand it over: a file on disk natively, or a
/// URL in the browser (a data: URL stands in for the picker's blob: URL).
Future<File> pickedPhoto(String name) async {
  if (kIsWeb) return File('data:image/jpeg;base64,${base64Encode(_photo)}');
  final dir = await Directory.systemTemp.createTemp('resq_upload_test');
  addTearDown(() => dir.delete(recursive: true));
  return File('${dir.path}/$name')..writeAsBytesSync(_photo);
}

void expectPhotoUpload(http.Request request, {required String filename}) {
  final body = latin1.decode(request.bodyBytes);
  expect(request.url.path, endsWith('/auto/upload'));
  expect(request.headers['content-type'], startsWith('multipart/form-data'));
  expect(body, contains('name="upload_preset"'));
  expect(body, contains('name="file"; filename="$filename"'));
  expect(body, contains(latin1.decode(_photo)));
}

void main() {
  test('uploads the photo bytes, so it works without file paths (web)', () async {
    final sent = <http.Request>[];
    final service = CameraServiceImpl(httpClient: cloudinary(sent), uploadFromBytes: true);

    final url = await service.uploadImage(await pickedPhoto('evidence_photo.jpg'));

    expect(url, _cloudUrl);
    expect(sent, hasLength(1));
    expectPhotoUpload(sent.single, filename: kIsWeb ? 'evidence' : 'evidence_photo.jpg');
  });

  test('uploads from bytes by default on web only', () {
    expect(CameraServiceImpl().uploadFromBytes, kIsWeb);
  });

  test('still streams the file from disk on Android', () async {
    final sent = <http.Request>[];
    final service = CameraServiceImpl(httpClient: cloudinary(sent), uploadFromBytes: false);

    final url = await service.uploadImage(await pickedPhoto('evidence_photo.jpg'));

    expect(url, _cloudUrl);
    expectPhotoUpload(sent.single, filename: 'evidence_photo.jpg');
  }, skip: kIsWeb ? 'Browsers have no files on disk' : false);
}
