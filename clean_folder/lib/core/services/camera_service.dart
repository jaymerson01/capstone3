import 'dart:io';

abstract class CameraService {
  Future<File?> pickImageFromGallery();
  Future<File?> pickImageFromCamera();
  Future<File?> pickVideoFromGallery();
  Future<File?> pickVideoFromCamera({Duration maxDuration = const Duration(seconds: 30)});
  Future<String> uploadImage(File imageFile);
  Future<String> uploadVideo(File videoFile);
  double getFileSizeInMB(File file);
}
