import 'dart:io';
import 'package:flutter/material.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/location_service.dart';
import 'package:community_safety_app/core/services/camera_service.dart';

class TestSandboxPage extends StatefulWidget {
  const TestSandboxPage({super.key});

  @override
  State<TestSandboxPage> createState() => _TestSandboxPageState();
}

class _TestSandboxPageState extends State<TestSandboxPage> {
  String _locationResult = "No location data fetched";
  File? _imageFile;
  bool _isLoadingLocation = false;

  Future<void> _testGps() async {
    setState(() {
      _isLoadingLocation = true;
      _locationResult = "Fetching GPS coordinates...";
    });
    try {
      final locationService = sl<LocationService>();
      final coordinate = await locationService.getCurrentLocation();
      setState(() {
        if (coordinate != null) {
          _locationResult =
              "Latitude: ${coordinate.latitude}\nLongitude: ${coordinate.longitude}";
        } else {
          _locationResult = "GPS returned null (Permissions denied or GPS disabled)";
        }
      });
    } catch (e) {
      setState(() {
        _locationResult = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _testCamera(bool fromCamera) async {
    try {
      final cameraService = sl<CameraService>();
      final file = fromCamera
          ? await cameraService.pickImageFromCamera()
          : await cameraService.pickImageFromGallery();
      setState(() {
        _imageFile = file;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Services Sandbox"),
        backgroundColor: const Color(0xFF49769F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.developer_mode,
                  size: 64,
                  color: Color(0xFF49769F),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Visual Sandbox Page",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Use this page to verify Location (GPS) and Camera services.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                
                // Location Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoadingLocation ? null : _testGps,
                          icon: const Icon(Icons.gps_fixed),
                          label: const Text("Test GPS"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF49769F),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _locationResult,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Camera Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _testCamera(true),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Camera"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF49769F),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _testCamera(false),
                              icon: const Icon(Icons.photo_library),
                              label: const Text("Gallery"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF49769F),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_imageFile != null) ...[
                          const Text(
                            "Selected Image Preview:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _imageFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ] else
                          const Text("No image selected"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
