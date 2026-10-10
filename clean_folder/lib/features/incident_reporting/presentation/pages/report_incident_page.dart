import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/location_service.dart';
import 'package:community_safety_app/core/services/camera_service.dart';
import 'package:community_safety_app/core/services/biometric_service.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/widgets/hidden_ai_trigger.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_text_field.dart';
import 'package:geolocator/geolocator.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/core/utils/incident_triage_helper.dart';
import 'package:community_safety_app/features/incident/data/datasources/incident_ai_remote_data_source.dart';
import 'package:community_safety_app/features/incident/presentation/pages/incident_detail_page.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';

class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  int currentStep = 2;

  final TextEditingController _coordinatesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _victimNameController = TextEditingController();
  final TextEditingController _victimPhoneController = TextEditingController();

  bool _isReportingOnBehalf = false;
  GoogleMapController? _miniMapController;
  bool _isReverseGeocoding = false;

  static const LatLng _defaultMoonwalkCenter = LatLng(14.4851, 121.0116);

  // Note: Quick sectors will be restored once local area/neighborhood names are gathered.
  /*
  static const List<Map<String, dynamic>> _quickSectors = [
    {"name": "Moonwalk Proper", "lat": 14.4851, "lng": 121.0116},
    {"name": "San Jose (Area 1)", "lat": 14.4895, "lng": 121.0105},
    {"name": "Airborne (Area 2)", "lat": 14.4835, "lng": 121.0090},
    {"name": "Multinational (Area 3)", "lat": 14.4940, "lng": 121.0185},
    {"name": "San Agustin (Area 4)", "lat": 14.4815, "lng": 121.0135},
    {"name": "Simplicio Cruz", "lat": 14.4862, "lng": 121.0142},
  ];
  */

  static const String _miniMapDarkStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#0d1627"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#8ec3b9"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#060d1a"}]},
  {"featureType": "administrative.country", "elementType": "geometry.stroke", "stylers": [{"color": "#1e2d4a"}]},
  {"featureType": "administrative.land_parcel", "elementType": "labels.text.fill", "stylers": [{"color": "#64779e"}]},
  {"featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [{"color": "#1e2d4a"}]},
  {"featureType": "landscape.man_made", "elementType": "geometry.stroke", "stylers": [{"color": "#1e2d4a"}]},
  {"featureType": "landscape.natural", "elementType": "geometry", "stylers": [{"color": "#08101e"}]},
  {"featureType": "poi", "elementType": "geometry", "stylers": [{"color": "#0f1c32"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#6f88b0"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#18263e"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#111c2f"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#98a6be"}]},
  {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#182740"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#061324"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#3d648f"}]}
]
''';

  String? _resolvedAddress;
  String? _resolvedSector;

  String _selectedComplainant = "self";
  String _selectedBarangay = "Area 1 - San Jose";
  
  bool isAiTriageEnabled = false;
  bool _isSubmittingReport = false;
  String _lastSubmittedCategory = "Other Emergency";
  String _lastSubmittedUrgency = "MEDIUM";
  String _lastSubmittedNarrative = "";
  String _lastSubmittedLocation = "Barangay Moonwalk";

  String? _selectedIncidentCategory;
  final TextEditingController _otherCategoryController =
      TextEditingController();
  final List<String> _incidentCategories = [
    "Fire Incident",
    "Theft / Robbery",
    "Medical Emergency",
    "Violence / Physical Fight",
    "Road Accident",
    "Suspicious Activity",
    "Flood / Calamity",
    "Lost Item / Missing Person",
    "Noise Complaint",
    "Other Emergency",
  ];

  double? _latitude;
  double? _longitude;
  String? _photoUrl;
  File? _selectedImageFile;
  bool _isUploadingImage = false;

  String? _videoUrl;
  File? _selectedVideoFile;
  bool _isUploadingVideo = false;
  double _selectedVideoSizeMB = 0.0;

  bool _isLocating = false;
  bool _isDraggingPin = false;

  @override
  void initState() {
    super.initState();
    context.read<IncidentBloc>().add(const StreamActiveIncidentsRequested());
  }

  @override
  void dispose() {
    _coordinatesController.dispose();
    _descriptionController.dispose();
    _landmarkController.dispose();
    _victimNameController.dispose();
    _victimPhoneController.dispose();
    _otherCategoryController.dispose();
    _miniMapController?.dispose();
    super.dispose();
  }

  bool get _isFormDirty {
    return _descriptionController.text.trim().isNotEmpty ||
        _selectedIncidentCategory != null ||
        _victimNameController.text.trim().isNotEmpty ||
        _victimPhoneController.text.trim().isNotEmpty ||
        _otherCategoryController.text.trim().isNotEmpty ||
        _selectedImageFile != null ||
        _selectedVideoFile != null ||
        _landmarkController.text.trim().isNotEmpty;
  }

  Future<bool> _showDiscardConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  color: AppColors.warning, size: 22),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Discard Report?",
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          "You have unsaved report details. Are you sure you want to leave? Your emergency report draft will be discarded.",
          style: TextStyle(
              color: AppColors.textLight, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text("Keep Editing",
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text("Discard",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });
    try {
      final locationService = sl<LocationService>();
      final coordinate = await locationService.getCurrentLocation();
      if (!mounted) return;

      if (coordinate != null) {
        setState(() {
          _latitude = coordinate.latitude;
          _longitude = coordinate.longitude;
          _resolvedAddress = BarangaySectorHelper.formatReadableAddress(
            resolvedAddress: coordinate.address,
            areaSector: coordinate.sector,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
          );
          _resolvedSector = coordinate.sector ??
              BarangaySectorHelper.findClosestSector(
                coordinate.latitude,
                coordinate.longitude,
              )['sector'] as String;
          if (_resolvedSector != null && _resolvedSector!.isNotEmpty) {
            _selectedBarangay = _resolvedSector!;
          }
          _coordinatesController.text =
              "${coordinate.latitude.toStringAsFixed(6)}, ${coordinate.longitude.toStringAsFixed(6)}";
        });

        if (_miniMapController != null) {
          _miniMapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(coordinate.latitude, coordinate.longitude),
                zoom: 16.5,
              ),
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("GPS pinned: ${_resolvedAddress!}"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.solved,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
      final isGpsOff = errorMessage.toLowerCase().contains('gps') ||
          errorMessage.toLowerCase().contains('location');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 5),
          action: isGpsOff
              ? SnackBarAction(
                  label: "Settings",
                  textColor: Colors.amber,
                  onPressed: () => sl<LocationService>().openLocationSettings(),
                )
              : null,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _updatePinnedLocation(
    double lat,
    double lng, {
    bool animateCamera = false,
    String? sectorHint,
  }) async {
    final offlineSector = (sectorHint != null && sectorHint.trim().isNotEmpty)
        ? {
            'sector': BarangaySectorHelper.normalizeSector(sectorHint),
            'address': "$sectorHint, Barangay Moonwalk, Parañaque City",
          }
        : BarangaySectorHelper.findClosestSector(lat, lng);

    setState(() {
      _latitude = lat;
      _longitude = lng;
      _coordinatesController.text = "${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";
      // Optimistically display human-readable Moonwalk sector immediately
      _resolvedAddress = offlineSector['address'] as String;
      _resolvedSector = offlineSector['sector'] as String;
      _selectedBarangay = offlineSector['sector'] as String;
      _isReverseGeocoding = true;
    });

    if (animateCamera && _miniMapController != null) {
      _miniMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, lng),
            zoom: 16.0,
          ),
        ),
      );
    }

    try {
      final coordinate = await sl<LocationService>().reverseGeocode(lat, lng);
      if (!mounted) return;
      if (coordinate != null) {
        final candidate = coordinate.address;
        final isClean = candidate != null &&
            candidate.trim().isNotEmpty &&
            !BarangaySectorHelper.isRawCoordinateOrGeneric(candidate);

        setState(() {
          if (isClean) {
            _resolvedAddress = candidate.trim();
          }
          if (coordinate.sector != null &&
              coordinate.sector!.isNotEmpty &&
              !BarangaySectorHelper.isRawCoordinateOrGeneric(coordinate.sector)) {
            _resolvedSector = coordinate.sector;
            _selectedBarangay = coordinate.sector!;
          }
        });
      }
    } catch (e) {
      debugPrint('[ReportIncident] Reverse geocoding error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isReverseGeocoding = false;
        });
      }
    }
  }

  Future<void> _chooseEvidenceFile() async {
    try {
      final file = await sl<CameraService>().pickImageFromGallery();
      if (file == null) return;

      setState(() {
        _selectedImageFile = file;
        _isUploadingImage = true;
      });

      try {
        final url = await sl<CameraService>().uploadImage(file);
        setState(() {
          _photoUrl = url;
        });
        if (!mounted) return;
        final isCloud = url.startsWith('http://') || url.startsWith('https://');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCloud
                ? "Evidence photo synced to ResQ Cloud!"
                : "Cloud upload skipped or timed out. Photo saved locally on device."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isCloud ? AppColors.secondary : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (uploadError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image saved locally (offline): ${uploadError.toString().split(']').last.trim()}"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to choose file: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _takeEvidencePhoto() async {
    try {
      final file = await sl<CameraService>().pickImageFromCamera();
      if (file == null) return;

      setState(() {
        _selectedImageFile = file;
        _isUploadingImage = true;
      });

      try {
        final url = await sl<CameraService>().uploadImage(file);
        setState(() {
          _photoUrl = url;
        });
        if (!mounted) return;
        final isCloud = url.startsWith('http://') || url.startsWith('https://');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCloud
                ? "Photo synced to ResQ Cloud!"
                : "Cloud upload skipped or timed out. Photo saved locally on device."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isCloud ? AppColors.secondary : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (uploadError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Photo saved locally (offline): ${uploadError.toString().split(']').last.trim()}"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to open camera: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _showVideoSizeWarningDialog(double sizeMB) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.danger),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
            SizedBox(width: 8),
            Text(
              "Video Limit Exceeded",
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          "Selected video is ${sizeMB.toStringAsFixed(1)} MB, which exceeds the emergency limit of 20 MB.\n\nTo prevent network delays during critical emergencies, please trim or record a shorter video clip (under 30 seconds).",
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text("Understood", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseVideoFile() async {
    try {
      final file = await sl<CameraService>().pickVideoFromGallery();
      if (file == null) return;

      final sizeMB = sl<CameraService>().getFileSizeInMB(file);
      if (sizeMB > 20.0) {
        if (!mounted) return;
        _showVideoSizeWarningDialog(sizeMB);
        return;
      }

      setState(() {
        _selectedVideoFile = file;
        _selectedVideoSizeMB = sizeMB;
        _isUploadingVideo = true;
      });

      try {
        final url = await sl<CameraService>().uploadVideo(file);
        setState(() {
          _videoUrl = url;
        });
        if (!mounted) return;
        final isCloud = url.startsWith('http://') || url.startsWith('https://');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCloud
                ? "Video evidence synced to ResQ Cloud!"
                : "Cloud upload skipped or timed out. Video saved locally on device."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isCloud ? AppColors.secondary : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (uploadError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Video saved locally (offline): ${uploadError.toString().split(']').last.trim()}"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to choose video: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      setState(() {
        _isUploadingVideo = false;
      });
    }
  }

  Future<void> _recordEvidenceVideo() async {
    try {
      final file = await sl<CameraService>().pickVideoFromCamera(
        maxDuration: const Duration(seconds: 30),
      );
      if (file == null) return;

      final sizeMB = sl<CameraService>().getFileSizeInMB(file);
      if (sizeMB > 20.0) {
        if (!mounted) return;
        _showVideoSizeWarningDialog(sizeMB);
        return;
      }

      setState(() {
        _selectedVideoFile = file;
        _selectedVideoSizeMB = sizeMB;
        _isUploadingVideo = true;
      });

      try {
        final url = await sl<CameraService>().uploadVideo(file);
        setState(() {
          _videoUrl = url;
        });
        if (!mounted) return;
        final isCloud = url.startsWith('http://') || url.startsWith('https://');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCloud
                ? "Video evidence synced to ResQ Cloud!"
                : "Cloud upload skipped or timed out. Video saved locally on device."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isCloud ? AppColors.secondary : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (uploadError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Video saved locally (offline): ${uploadError.toString().split(']').last.trim()}"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to record video: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      setState(() {
        _isUploadingVideo = false;
      });
    }
  }

  Future<void> _executeStandardSubmit({String? urgencyStatus}) async {
    // 🛡️ Anti-Prank / Anti-Spam Biometric Gate
    final biometricService = sl<BiometricService>();
    final isBiometricAvailable = await biometricService.isBiometricAvailable();
    if (isBiometricAvailable) {
      final verified = await biometricService.verifySubmission(
        reason:
            "Verify your biometric identity to submit an official emergency report to Barangay Moonwalk responders.",
      );
      if (!verified) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Submission cancelled: Identity verification is required."),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (!mounted) return;

    final double lat = _latitude ??
        (_isReportingOnBehalf ? _defaultMoonwalkCenter.latitude : 0.0);
    final double lng = _longitude ??
        (_isReportingOnBehalf ? _defaultMoonwalkCenter.longitude : 0.0);

    final String customOther = _otherCategoryController.text.trim();
    final String finalCategory =
        (_selectedIncidentCategory == 'Other Emergency' && customOther.isNotEmpty)
            ? "Other Emergency ($customOther)"
            : (_selectedIncidentCategory ?? 'Unknown Incident');

    final String categoryForTriage =
        (_selectedIncidentCategory == 'Other Emergency' && customOther.isNotEmpty)
            ? customOther
            : (_selectedIncidentCategory ?? 'Other Emergency');

    final effectiveUrgency = urgencyStatus ??
        IncidentTriageHelper.getBaselineUrgency(categoryForTriage);

    final authState = context.read<AuthBloc>().state;
    final isAuth = authState is Authenticated;
    final currentUser = isAuth ? authState.user : null;
    final currentUserId = (currentUser?.id != null && currentUser!.id.isNotEmpty && currentUser.id != 'resident_local')
        ? currentUser.id
        : (FirebaseAuth.instance.currentUser?.uid ?? 'resident_local');
    final currentUserName = currentUser?.fullName ??
        (currentUser?.email.isNotEmpty == true
            ? currentUser!.email.split('@').first
            : 'Citizen');
    final currentUserEmail = currentUser?.email ?? '';

    final bool isAnonymous = _selectedComplainant == 'anonymous';

    final String readableBase = BarangaySectorHelper.formatReadableAddress(
      resolvedAddress: _resolvedAddress,
      areaSector: _resolvedSector ?? _selectedBarangay,
      latitude: lat,
      longitude: lng,
    );

    final String locationAddress = _landmarkController.text.trim().isNotEmpty
        ? "$readableBase (${_landmarkController.text.trim()})"
        : readableBase;

    final String cleanSector = BarangaySectorHelper.normalizeSector(
      _resolvedSector ?? _selectedBarangay,
      readableBase,
    );

    // Save metadata for post-submit modal
    _lastSubmittedCategory = finalCategory;
    _lastSubmittedUrgency = effectiveUrgency;
    _lastSubmittedNarrative = _descriptionController.text.trim();
    _lastSubmittedLocation = locationAddress;

    final incident = IncidentEntity(
      id: '',
      reporterId: currentUserId,
      category: finalCategory,
      description: _descriptionController.text.trim(),
      latitude: lat,
      longitude: lng,
      photoUrl: _photoUrl,
      videoUrl: _videoUrl,
      status: 'Pending',
      urgencyStatus: effectiveUrgency,
      timestamp: DateTime.now(),
      resolvedAddress: locationAddress,
      areaSector: cleanSector,
      isAnonymous: isAnonymous,
      reporterName: currentUserName,
      reporterEmail: currentUserEmail,
      isReportingOnBehalf: _isReportingOnBehalf,
      victimName:
          _isReportingOnBehalf ? _victimNameController.text.trim() : null,
      victimPhone: _isReportingOnBehalf &&
              _victimPhoneController.text.trim().isNotEmpty
          ? _victimPhoneController.text.trim()
          : null,
    );

    // Display high-tech OLED submission loading dialog
    _isSubmittingReport = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFF0D1627),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Color(0xFF1E2D4A)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  height: 42,
                  width: 42,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF00E5FF),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Submitting Emergency Report",
                  style: TextStyle(
                    color: Color(0xFFE8F0FE),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Dispatching ticket to Barangay Moonwalk responders...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF7B8DB0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    context.read<IncidentBloc>().add(SubmitIncidentReportRequested(incident));
  }

  void _submitReport() {
    if (_isReportingOnBehalf && _victimNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Please enter the name of the person you are reporting for."),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedIncidentCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Please select an incident category before submitting."),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedIncidentCategory == 'Other Emergency' &&
        _otherCategoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Please specify the emergency type (e.g. Fallen Electric Wire, Gas Leak, Sinkhole)."),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a description of the incident"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_isUploadingImage || _isUploadingVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait a moment, evidence media is uploading to cloud..."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    // Check for nearby duplicate incidents (within 250m, same category, within 2h)
    final duplicateMatch = _findNearbyDuplicateIncident();
    if (duplicateMatch != null) {
      _showDuplicateInterceptionDialog(
        duplicateMatch.$1,
        duplicateMatch.$2,
      );
      return;
    }

    _executeStandardSubmit();
  }

  (IncidentEntity, double)? _findNearbyDuplicateIncident() {
    if (_latitude == null ||
        _longitude == null ||
        _selectedIncidentCategory == null) {
      return null;
    }

    final incidentState = context.read<IncidentBloc>().state;
    if (incidentState is! IncidentLoaded) return null;

    final activeIncidents = incidentState.incidents.where((inc) {
      return inc.status.toLowerCase() != 'resolved' &&
          inc.latitude != 0.0 &&
          inc.longitude != 0.0;
    }).toList();

    (IncidentEntity, double)? closestMatch;
    double minDistance = double.infinity;

    for (final inc in activeIncidents) {
      final currentCat = _selectedIncidentCategory!.toLowerCase();
      final incCat = inc.category.toLowerCase();
      final isCatMatch = currentCat.contains(incCat) ||
          incCat.contains(currentCat) ||
          (currentCat.contains('fire') && incCat.contains('fire')) ||
          (currentCat.contains('theft') && incCat.contains('theft')) ||
          (currentCat.contains('medical') && incCat.contains('medical')) ||
          (currentCat.contains('flood') && incCat.contains('flood')) ||
          (currentCat.contains('accident') && incCat.contains('accident')) ||
          (currentCat.contains('violence') && incCat.contains('violence'));

      if (!isCatMatch) continue;

      final hoursDiff = DateTime.now().difference(inc.timestamp).inHours;
      if (hoursDiff >= 2) continue;

      final distance = Geolocator.distanceBetween(
        _latitude!,
        _longitude!,
        inc.latitude,
        inc.longitude,
      );

      if (distance <= 250.0 && distance < minDistance) {
        minDistance = distance;
        closestMatch = (inc, distance);
      }
    }

    return closestMatch;
  }
  void _showDuplicateInterceptionDialog(
    IncidentEntity duplicate,
    double distanceInMeters,
  ) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId =
        authState is Authenticated ? authState.user.id : "resident_demo_01";
    final isMyOwnReport = duplicate.reporterId == currentUserId;
    final hasVoted = duplicate.validatedUserIds.contains(currentUserId);
    final minutesAgo = DateTime.now().difference(duplicate.timestamp).inMinutes;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: (isMyOwnReport ? AppColors.primary : AppColors.pending)
                .withValues(alpha: 0.4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (isMyOwnReport ? AppColors.primary : AppColors.pending)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (isMyOwnReport ? AppColors.primary : AppColors.pending)
                            .withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      isMyOwnReport
                          ? Icons.check_circle_outline_rounded
                          : Icons.notifications_active_rounded,
                      color: isMyOwnReport ? AppColors.primary : AppColors.pending,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMyOwnReport
                              ? "You Already Reported This!"
                              : "Similar Incident Nearby!",
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          isMyOwnReport
                              ? "Your ticket was filed ${minutesAgo == 0 ? 'just now' : '$minutesAgo mins ago'}"
                              : "Potential duplicate detected within 250m",
                          style: TextStyle(
                            color: isMyOwnReport ? AppColors.primary : AppColors.pending,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.near_me_rounded,
                            color: AppColors.primary, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "${distanceInMeters.round()} meters from your location",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isMyOwnReport) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Your Report",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      duplicate.category,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      duplicate.description,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people_alt_rounded,
                            color: AppColors.textLight, size: 14),
                        SizedBox(width: 6),
                        Text(
                          "${duplicate.upvoteCount + 1} citizen${(duplicate.upvoteCount + 1) == 1 ? '' : 's'} affected",
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              Text(
                isMyOwnReport
                    ? "Your earlier report is active (Status: ${duplicate.status}). Emergency dispatch and Tanods have already been alerted."
                    : "Corroborating ('Me Too') the existing report prevents overloading emergency dispatchers and elevates emergency urgency.",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 22),

              // Button 1: Primary Action (View My Report vs Me Too)
              GestureDetector(
                onTap: () {
                  Navigator.pop(dialogCtx);
                  if (!isMyOwnReport && !hasVoted) {
                    context.read<IncidentBloc>().add(
                          UpvoteIncidentRequested(
                            duplicate.id,
                            currentUserId,
                          ),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "You corroborated this incident! Emergency priority escalated.",
                        ),
                        backgroundColor: AppColors.solved,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IncidentDetailPage(
                        initialIncident: duplicate,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.primaryGlowShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isMyOwnReport
                            ? Icons.assignment_turned_in_rounded
                            : Icons.front_hand_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        isMyOwnReport
                            ? "View My Active Report & Notes"
                            : "Me Too / Corroborate Incident",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Button 2: "Submit as Separate Incident / Anyway"
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    if (isAiTriageEnabled) {
                      context.read<IncidentBloc>().add(
                          AnalyzeIncidentNarrativeEvent(
                              _descriptionController.text.trim()));
                    } else {
                      _executeStandardSubmit();
                    }
                  },
                  child: Text(
                    isMyOwnReport
                        ? "Submit New Separate Report Anyway"
                        : "Submit as Separate Incident",
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFileDisplayText() {
    if (_isUploadingImage) {
      return "Uploading image...";
    }
    if (_selectedImageFile == null) {
      return "No file chosen";
    }
    return _selectedImageFile!.path.split('/').last.split('\\').last;
  }

  Widget _buildAppLogo() {
    return HiddenAiTrigger(
      onTriggered: () {
        setState(() {
          isAiTriageEnabled = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("AI Triage Enabled"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: SizedBox(
        height: 34,
        width: 34,
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.security, size: 18, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  void _showEmergencyCallConfirmation(String agencyName, String phoneNumber) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger.withValues(alpha: 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(Icons.phone_in_talk_rounded,
                    color: AppColors.danger, size: 30),
              ),
              SizedBox(height: 16),
              Text(
                'Call $agencyName?',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Dial the official hotline for $agencyName ($phoneNumber) now?',
                style: TextStyle(
                    color: AppColors.textLight, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(ctx);
                        final cleanNumber =
                            phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
                        final Uri phoneUri =
                            Uri(scheme: 'tel', path: cleanNumber);
                        try {
                          final launched = await launchUrl(
                            phoneUri,
                            mode: LaunchMode.externalApplication,
                          );
                          if (!launched) {
                            throw 'Cannot launch dialer';
                          }
                        } catch (_) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Could not open dialer for $phoneNumber. Please dial manually.'),
                              backgroundColor: AppColors.danger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: AppColors.emergencyGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppColors.dangerGlowShadow,
                        ),
                        child: Center(
                          child: Text(
                            'Call Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncidentBloc, IncidentState>(
      listener: (context, state) {
        if (state is IncidentSubmitSuccess) {
          if (_isSubmittingReport) {
            Navigator.of(context, rootNavigator: true).pop();
            _isSubmittingReport = false;
          }
          _showPostSubmitSafetyWindow(
            category: _lastSubmittedCategory,
            urgency: _lastSubmittedUrgency,
            narrative: _lastSubmittedNarrative,
            location: _lastSubmittedLocation,
          );
        } else if (state is IncidentSubmitFailure) {
          if (_isSubmittingReport) {
            Navigator.of(context, rootNavigator: true).pop();
            _isSubmittingReport = false;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to submit: ${state.message}"),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is IncidentTriageLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: Custom3dCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text("Gemini AI is analyzing incident threat levels...",
                        style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        } else if (state is IncidentTriageError) {
          Navigator.of(context).pop(); // dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("AI Evaluation failed. Defaulting to MEDIUM priority."),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _executeStandardSubmit(urgencyStatus: 'MEDIUM');
        } else if (state is IncidentTriageLoaded) {
          Navigator.of(context).pop(); // dismiss loading
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.primary)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("AI Urgency Assessment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    SizedBox(height: 12),
                    Text("${state.triageResult.urgency} - ${state.triageResult.justification}", style: TextStyle(fontSize: 14, color: AppColors.textLight)),
                    SizedBox(height: 20),
                    Custom3dButton(
                      text: "Proceed to Submit",
                      onPressed: () {
                        Navigator.of(context).pop();
                        _executeStandardSubmit(urgencyStatus: state.triageResult.urgency);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: !_isFormDirty,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _showDiscardConfirmationDialog();
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
                tooltip: "Back",
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              backgroundColor: AppColors.surface,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: AppColors.border,
                  height: 1,
                ),
              ),
              iconTheme: IconThemeData(color: AppColors.textDark),
              titleSpacing: 0,
              title: Row(
                children: [
                  _buildAppLogo(),
                  SizedBox(width: 12),
                  Text(
                    "Report Incident",
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceLight,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.help_outline,
                          color: AppColors.textLight, size: 20),
                      tooltip: "Filing Guidelines",
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Ensure accurate data for priority responder handling."),
                            backgroundColor: AppColors.surface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.border),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmergencyHotlinesSection(),
                  SizedBox(height: 20),
                  _buildPrimaryFormContainer(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyHotlinesSection() {
    return Custom3dCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.flash_on,
                  color: AppColors.danger,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Immediate Threat? Emergency Hotlines",
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showEmergencyCallConfirmation(
                      "Emergency Hotline", "911"),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.emergencyGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppColors.dangerGlowShadow,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Call 911",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showEmergencyCallConfirmation(
                      "Barangay Desk", "0917-000-0000"),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined,
                              color: AppColors.primary, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Barangay Desk",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryFormContainer(IncidentState state) {
    return Custom3dCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Incident Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 18),

          // ── Reporting Mode Selector: Myself (At Scene) vs. On Behalf ───────
          Text(
            "Reporting Mode",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isReportingOnBehalf = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isReportingOnBehalf ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: !_isReportingOnBehalf
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_pin_circle_rounded,
                            size: 16,
                            color: !_isReportingOnBehalf ? Colors.white : AppColors.textLight,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "Myself",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: !_isReportingOnBehalf ? Colors.white : AppColors.textLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isReportingOnBehalf = true;
                      });
                      if (_latitude == null || _latitude == 0.0) {
                        _updatePinnedLocation(
                          _defaultMoonwalkCenter.latitude,
                          _defaultMoonwalkCenter.longitude,
                          animateCamera: true,
                          sectorHint: _selectedBarangay,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isReportingOnBehalf ? const Color(0xFFFF9500) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _isReportingOnBehalf
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF9500).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            size: 16,
                            color: _isReportingOnBehalf ? Colors.black : AppColors.textLight,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "For Someone",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: _isReportingOnBehalf ? Colors.black : AppColors.textLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14),

          // ── Victim Dossier Form (Active when Reporting on Behalf) ───────────
          if (_isReportingOnBehalf) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF9500).withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.emergency_share_rounded, size: 16, color: Color(0xFFFF9500)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Reporting for Someone Else (Off-Site)",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF9500),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Enter the affected person's details and adjust the map pin below to their exact location in Barangay Moonwalk so responders can locate and assist them.",
                    style: TextStyle(fontSize: 11.5, color: AppColors.textLight, height: 1.4),
                  ),
                  SizedBox(height: 12),
                  Custom3dTextField(
                    controller: _victimNameController,
                    labelText: "Affected Person's Full Name *",
                    hintText: "E.g. Maria Santos / Lola Elena",
                    prefixIcon: Icons.person_rounded,
                  ),
                  SizedBox(height: 10),
                  Custom3dTextField(
                    controller: _victimPhoneController,
                    labelText: "Affected Person's Contact Number (Optional)",
                    hintText: "E.g. 0917 123 4567 (for responder verification)",
                    prefixIcon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ],

          // Complainant Selection
          Text(
            "Complainant Identity",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          SizedBox(height: 8),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final userName = authState is Authenticated
                  ? (authState.user.fullName ??
                      (authState.user.email.isNotEmpty
                          ? authState.user.email.split('@').first
                          : 'Resident'))
                  : 'Resident';
              return DropdownButtonFormField<String>(
                initialValue: _selectedComplainant,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.accentBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
                ),
                items: [
                  DropdownMenuItem(
                    value: "self",
                    child: Text(
                      "Self: $userName",
                      style: TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: "anonymous",
                    child: Text(
                      "Anonymous (Identity Shielded)",
                      style: TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedComplainant = val ?? "self"),
              );
            },
          ),

          SizedBox(height: 16),

          // ── Real GPS / Interactive Location Section ────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _isReportingOnBehalf ? "Victim / Incident Location" : "Incident Location",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Pinned Location Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _latitude != null
                    ? (_isReportingOnBehalf
                        ? const Color(0xFFFF9500).withValues(alpha: 0.4)
                        : AppColors.solved.withValues(alpha: 0.4))
                    : AppColors.border,
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _latitude != null
                        ? (_isReportingOnBehalf
                            ? const Color(0xFFFF9500).withValues(alpha: 0.12)
                            : AppColors.solved.withValues(alpha: 0.12))
                        : AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _latitude != null
                        ? Icons.pin_drop_rounded
                        : Icons.location_searching_rounded,
                    color: _latitude != null
                        ? (_isReportingOnBehalf ? const Color(0xFFFF9500) : AppColors.solved)
                        : AppColors.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _resolvedAddress ?? "Location not pinned yet",
                              style: TextStyle(
                                color: _resolvedAddress != null ? AppColors.textDark : AppColors.textLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (_isReverseGeocoding)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        _latitude != null
                            ? "Coordinates: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}${_resolvedSector != null ? ' • $_resolvedSector' : ''}"
                            : "Drag pin or tap map below to pin exact house / compound",
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          // ── Interactive Draggable Pin Google Map ───────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isReportingOnBehalf
                      ? const Color(0xFFFF9500).withValues(alpha: 0.5)
                      : AppColors.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _latitude ?? _defaultMoonwalkCenter.latitude,
                        _longitude ?? _defaultMoonwalkCenter.longitude,
                      ),
                      zoom: 15.5,
                    ),
                    style: _miniMapDarkStyle,
                    onMapCreated: (controller) {
                      _miniMapController = controller;
                    },
                    onTap: (LatLng tapPos) {
                      _updatePinnedLocation(tapPos.latitude, tapPos.longitude);
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('draggable_incident_pin'),
                        position: LatLng(
                          _latitude ?? _defaultMoonwalkCenter.latitude,
                          _longitude ?? _defaultMoonwalkCenter.longitude,
                        ),
                        draggable: true,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          _isReportingOnBehalf ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueRed,
                        ),
                        infoWindow: InfoWindow(
                          title: _isReportingOnBehalf ? "Victim Location" : "Incident Location",
                          snippet: _resolvedAddress ?? "Drag to refine location",
                        ),
                        onDragStart: (LatLng startPos) {
                          setState(() {
                            _isDraggingPin = true;
                          });
                        },
                        onDrag: (LatLng currentPos) {
                          _coordinatesController.text =
                              "${currentPos.latitude.toStringAsFixed(6)}, ${currentPos.longitude.toStringAsFixed(6)}";
                        },
                        onDragEnd: (LatLng newPos) {
                          setState(() {
                            _isDraggingPin = false;
                          });
                          _updatePinnedLocation(newPos.latitude, newPos.longitude);
                        },
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                  ),
                  // Top overlay guide badge
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isDraggingPin
                              ? (_isReportingOnBehalf ? const Color(0xFFFF9500) : AppColors.primary)
                              : Colors.white12,
                          width: _isDraggingPin ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isDraggingPin ? Icons.open_with_rounded : Icons.touch_app_rounded,
                            size: 14,
                            color: _isReportingOnBehalf ? const Color(0xFFFF9500) : AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _isDraggingPin
                                  ? "Dragging pin: release to drop at exact location"
                                  : (_isReverseGeocoding
                                      ? "Resolving Moonwalk street & sector..."
                                      : "Touch & drag pin freely, or tap anywhere to place"),
                              style: TextStyle(
                                fontSize: 10.5,
                                color: _isDraggingPin
                                    ? (_isReportingOnBehalf ? const Color(0xFFFF9500) : AppColors.primary)
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isReverseGeocoding && !_isDraggingPin)
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom-right re-center button
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton.small(
                      heroTag: 'recenter_pin_btn',
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                      elevation: 3,
                      onPressed: () {
                        if (_miniMapController != null) {
                          _miniMapController!.animateCamera(
                            CameraUpdate.newLatLng(
                              LatLng(
                                _latitude ?? _defaultMoonwalkCenter.latitude,
                                _longitude ?? _defaultMoonwalkCenter.longitude,
                              ),
                            ),
                          );
                        }
                      },
                      child: Icon(Icons.center_focus_strong_rounded, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),

          // Action Button: Pin / Re-Pin with Phone GPS
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _latitude != null ? AppColors.surfaceLight : AppColors.primary,
                foregroundColor: _latitude != null ? AppColors.primary : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: _latitude != null
                      ? BorderSide(color: AppColors.primary, width: 1.2)
                      : BorderSide.none,
                ),
                elevation: _latitude != null ? 0 : 2,
              ),
              onPressed: _isLocating ? null : _getCurrentLocation,
              icon: _isLocating
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      _latitude != null ? Icons.refresh_rounded : Icons.my_location_rounded,
                      size: 18,
                    ),
              label: Text(
                _isLocating
                    ? "Acquiring GPS & Address..."
                    : (_latitude != null ? "Use My Phone GPS Fix" : "Pin Exact Location with GPS"),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
          SizedBox(height: 12),

          // Landmark Note Input
          Custom3dTextField(
            controller: _landmarkController,
            labelText: "Nearby Landmark / Specific Details (Optional)",
            hintText: "E.g. Near gate 2, corner store, 3rd floor unit",
            prefixIcon: Icons.add_location_alt_outlined,
          ),
          SizedBox(height: 16),

          // Incident Category Selection
          Text(
            "Incident Category",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedIncidentCategory,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            hint: Text("Select Category", style: TextStyle(color: AppColors.textLight, fontSize: 13)),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.accentBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
            ),
            items: _incidentCategories.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(cat), size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cat,
                        style: TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedIncidentCategory = val;
              });
            },
          ),

          if (_selectedIncidentCategory == 'Other Emergency') ...[
            SizedBox(height: 12),
            Custom3dTextField(
              controller: _otherCategoryController,
              labelText: "Specify Emergency Type",
              hintText:
                  "e.g., Fallen Electric Wire, Gas Leak, Sinkhole, Oil Spill",
              prefixIcon: Icons.emergency_outlined,
            ),
          ],

          SizedBox(height: 16),

          // Description 3D text field
          Custom3dTextField(
            controller: _descriptionController,
            labelText: "Incident Description",
            hintText: "Provide details of what happened, people involved, etc.",
            prefixIcon: Icons.description_outlined,
            maxLines: 4,
          ),

          SizedBox(height: 12),

          // Evidence Attachment Button
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isUploadingImage ? null : _chooseEvidenceFile,
                  icon: Icon(Icons.photo_library_outlined),
                  label: Text(_getFileDisplayText(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  onPressed: _isUploadingImage ? null : _takeEvidencePhoto,
                ),
              ),
            ],
          ),

          if (_selectedImageFile != null) ...[
            SizedBox(height: 12),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImageFile!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageFile = null;
                        _photoUrl = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                if (_isUploadingImage)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          SizedBox(height: 16),

          // Video Evidence Section (Low Latency / Max 20MB / 30s)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.progress,
                    side: BorderSide(color: AppColors.progress),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isUploadingVideo ? null : _chooseVideoFile,
                  icon: Icon(Icons.video_library_outlined),
                  label: Text(
                    _isUploadingVideo
                        ? "Uploading video..."
                        : (_selectedVideoFile == null ? "Add Video (≤ 20MB)" : "Change Video"),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: IconButton(
                  icon: Icon(Icons.videocam_outlined, color: AppColors.progress),
                  onPressed: _isUploadingVideo ? null : _recordEvidenceVideo,
                ),
              ),
            ],
          ),

          if (_selectedVideoFile != null) ...[
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.progress.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.progress.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.videocam_rounded, color: AppColors.progress, size: 20),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedVideoFile!.path.split('/').last.split('\\').last,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          "${_selectedVideoSizeMB.toStringAsFixed(1)} MB • Emergency low-latency verified",
                          style: TextStyle(
                            color: AppColors.progress,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isUploadingVideo)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.progress),
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.textLight, size: 18),
                      onPressed: () {
                        setState(() {
                          _selectedVideoFile = null;
                          _videoUrl = null;
                          _selectedVideoSizeMB = 0.0;
                        });
                      },
                    ),
                ],
              ),
            ),
          ],


          SizedBox(height: 24),

          // 3D Submit Button
          if (state is IncidentSubmitLoading || state is IncidentTriageLoading)
            Center(child: CircularProgressIndicator(color: AppColors.primary))
          else
            Custom3dButton(
              icon: Icons.send_rounded,
              text: "SUBMIT INCIDENT REPORT",
              onPressed: _submitReport,
            ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Fire Incident":
        return Icons.local_fire_department;
      case "Theft / Robbery":
        return Icons.local_police;
      case "Medical Emergency":
        return Icons.medical_services;
      case "Violence / Physical Fight":
        return Icons.warning_amber_rounded;
      case "Road Accident":
        return Icons.car_crash;
      case "Suspicious Activity":
        return Icons.visibility;
      case "Flood / Calamity":
        return Icons.flood;
      case "Lost Item / Missing Person":
        return Icons.person_search;
      case "Noise Complaint":
        return Icons.volume_up;
      default:
        return Icons.report_problem;
    }
  }

  List<String> _getSafetyGuidelines(String category) {
    switch (category) {
      case "Fire Incident":
        return [
          "Leave the burning area immediately. Do not try to save belongings.",
          "Warn nearby people and help children, elderly, or persons with disability if safe.",
          "Stay low if there is smoke and cover your nose/mouth with cloth.",
          "Do not use elevators. Use stairs or the safest exit route.",
          "Call the fire station or emergency hotline immediately.",
          "Move to an open and safe area away from the fire.",
        ];
      case "Theft / Robbery":
        return [
          "Do not chase or confront the suspect.",
          "Move to a safe and crowded area immediately.",
          "Observe details only if safe: clothing, direction, vehicle plate, or appearance.",
          "Call police or barangay responders right away.",
        ];
      case "Medical Emergency":
        return [
          "Call an ambulance or emergency hotline immediately.",
          "Keep the patient calm and do not move them unless the area is unsafe.",
          "Check if the person is breathing and responsive.",
        ];
      case "Road Accident":
        return [
          "Move to a safe side of the road if you are not injured.",
          "Do not move injured persons unless there is immediate danger.",
          "Call emergency responders or ambulance immediately.",
        ];
      default:
        return [
          "Move to a safe location first.",
          "Call the proper emergency hotline if there is immediate danger.",
          "Avoid touching evidence or confronting involved persons.",
          "Provide accurate details to responders.",
        ];
    }
  }

  void _showPostSubmitSafetyWindow({
    required String category,
    required String urgency,
    required String narrative,
    required String location,
  }) {
    final List<String> guidelines = _getSafetyGuidelines(category);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _PostSubmitSafetyDialog(
          category: category,
          urgency: urgency,
          narrative: narrative,
          location: location,
          categoryIcon: _getCategoryIcon(category),
          fallbackGuidelines: guidelines,
          onDismiss: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop(); // Return cleanly to dashboard
          },
        );
      },
    );
  }
}

// ─── Post-Submit Safety Dialog with Gemini AI Precautions ────────────────────

class _PostSubmitSafetyDialog extends StatefulWidget {
  final String category;
  final String urgency;
  final String narrative;
  final String location;
  final IconData categoryIcon;
  final List<String> fallbackGuidelines;
  final VoidCallback onDismiss;

  const _PostSubmitSafetyDialog({
    required this.category,
    required this.urgency,
    required this.narrative,
    required this.location,
    required this.categoryIcon,
    required this.fallbackGuidelines,
    required this.onDismiss,
  });

  @override
  State<_PostSubmitSafetyDialog> createState() =>
      _PostSubmitSafetyDialogState();
}

class _PostSubmitSafetyDialogState extends State<_PostSubmitSafetyDialog> {
  bool _isLoadingAi = true;
  List<String> _aiMeasures = [];

  @override
  void initState() {
    super.initState();
    _fetchAiMeasures();
  }

  Future<void> _fetchAiMeasures() async {
    try {
      final aiDataSource = sl<IncidentAiRemoteDataSource>();
      final measures = await aiDataSource.generatePrecautionaryMeasures(
        category: widget.category,
        narrative: widget.narrative,
        location: widget.location,
      );
      if (mounted) {
        setState(() {
          _aiMeasures = measures;
          _isLoadingAi = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingAi = false;
        });
      }
    }
  }

  (Color, IconData, String, String) _getUrgencyVisuals(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'CRITICAL':
        return (
          AppColors.danger,
          Icons.warning_amber_rounded,
          "CRITICAL PRIORITY",
          "Immediate responder dispatch triggered.",
        );
      case 'HIGH':
        return (
          const Color(0xFFFF9F0A),
          Icons.error_outline_rounded,
          "HIGH PRIORITY",
          "Active hazard • Priority response queue.",
        );
      case 'MEDIUM':
        return (
          AppColors.primary,
          Icons.info_outline_rounded,
          "MEDIUM PRIORITY",
          "Patrol unit notified for investigation.",
        );
      case 'LOW':
      default:
        return (
          AppColors.solved,
          Icons.check_circle_outline_rounded,
          "STANDARD PRIORITY",
          "Logged for municipal desk review.",
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (urgencyColor, urgencyIcon, urgencyTitle, urgencySubtitle) =
        _getUrgencyVisuals(widget.urgency);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.categoryIcon,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Report Dispatched",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          widget.category,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Dynamic Assessed Priority Card (Replacing static "Pending Evaluation")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: urgencyColor.withValues(alpha: 0.4), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: urgencyColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(urgencyIcon, color: urgencyColor, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                urgencyTitle,
                                style: TextStyle(
                                  color: urgencyColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: urgencyColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "ASSESSED",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            urgencySubtitle,
                            style: TextStyle(
                              color: AppColors.textLight.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Gemini AI Precautionary Advisory Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF00E5FF),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "AI Safety Advice",
                          style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Gemini 3.5",
                            style: TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    if (_isLoadingAi) ...[
                      Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF00E5FF),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Generating tailored safety advice for your situation...",
                              style: TextStyle(
                                color: AppColors.textLight.withValues(alpha: 0.8),
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_aiMeasures.isNotEmpty) ...[
                      Column(
                        children: _aiMeasures.map((measure) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.shield_outlined,
                                    size: 13,
                                    color: Color(0xFF00E5FF),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    measure,
                                    style: TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 12,
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      Column(
                        children: widget.fallbackGuidelines.map((guideline) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.shield_outlined,
                                    size: 13,
                                    color: Color(0xFF00E5FF),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    guideline,
                                    style: TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 12,
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Action Button
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onDismiss,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppColors.primaryGlowShadow,
                        ),
                        child: Center(
                          child: Text(
                            "I Understand & Done",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
