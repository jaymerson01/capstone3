import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'camera_service.dart';

class CameraServiceImpl implements CameraService {
  final ImagePicker _picker;
  final FirebaseStorage _storage;

  CameraServiceImpl({
    ImagePicker? picker,
    FirebaseStorage? storage,
  })  : _picker = picker ?? ImagePicker(),
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  @override
  Future<File?> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  @override
  Future<String> uploadImage(File imageFile) async {
    final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('incident_photos/$fileName');
    
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
