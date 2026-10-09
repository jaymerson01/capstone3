import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:community_safety_app/core/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'camera_service.dart';

class CameraServiceImpl implements CameraService {
  final ImagePicker _picker;
  final http.Client _httpClient;

  CameraServiceImpl({
    ImagePicker? picker,
    http.Client? httpClient,
  })  : _picker = picker ?? ImagePicker(),
        _httpClient = httpClient ?? http.Client();

  @override
  Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80,
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  @override
  Future<File?> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80,
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  @override
  Future<File?> pickVideoFromGallery() async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 30),
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  @override
  Future<File?> pickVideoFromCamera({
    Duration maxDuration = const Duration(seconds: 30),
  }) async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: maxDuration,
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  @override
  double getFileSizeInMB(File file) {
    try {
      final bytes = file.lengthSync();
      return bytes / (1024 * 1024);
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Future<String> uploadImage(File imageFile) async {
    return _uploadToCloudinary(imageFile, isVideo: false);
  }

  @override
  Future<String> uploadVideo(File videoFile) async {
    return _uploadToCloudinary(videoFile, isVideo: true);
  }

  Future<String> _uploadToCloudinary(File file, {required bool isVideo}) async {
    const cloudName = AppConfig.cloudinaryCloudName;
    const uploadPreset = AppConfig.cloudinaryUploadPreset;

    const maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final fileSizeKB = (file.lengthSync() / 1024).toStringAsFixed(1);
        debugPrint(
            "Uploading ${isVideo ? 'video' : 'image'} ($fileSizeKB KB) to Cloudinary ($cloudName) [Attempt $attempt/$maxRetries]...");

        final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
        );

        final request = http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..fields['folder'] = isVideo ? 'resq_videos' : 'resq_photos'
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

        final streamedResponse = await _httpClient.send(request).timeout(
              Duration(seconds: isVideo ? 120 : 60),
            );

        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final secureUrl = data['secure_url'] as String?;
          if (secureUrl != null && secureUrl.isNotEmpty) {
            // If it's a video, ensure Cloudinary serves universal H.264 MP4 so that all browsers and desktop players can decode it
            final finalUrl = (isVideo &&
                    secureUrl.contains('/video/upload/') &&
                    !secureUrl.contains('/vc_h264'))
                ? secureUrl.replaceFirst('/video/upload/', '/video/upload/vc_h264,f_mp4/')
                : secureUrl;
            debugPrint("Cloudinary upload SUCCESS: $finalUrl");
            return finalUrl;
          }
        }
        debugPrint(
            "Cloudinary upload failed (HTTP ${response.statusCode}): ${response.body}");
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 1500));
        }
      } catch (e) {
        debugPrint("Cloudinary upload attempt $attempt error: $e");
        if (attempt < maxRetries) {
          debugPrint("Retrying Cloudinary upload in 1.5s...");
          await Future.delayed(const Duration(milliseconds: 1500));
        } else {
          // Graceful offline fallback after all retries exhausted
          return file.uri.toString();
        }
      }
    }
    return file.uri.toString();
  }
}
