import 'dart:io';

abstract class CameraService {
  Future<File?> pickImageFromGallery();
  Future<File?> pickImageFromCamera();
  Future<String> uploadImage(File imageFile);
}
