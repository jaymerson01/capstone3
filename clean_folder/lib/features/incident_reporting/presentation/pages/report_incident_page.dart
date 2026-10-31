import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/map_styles.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/location_service.dart';
import 'package:community_safety_app/core/services/camera_service.dart';
import 'package:community_safety_app/core/services/biometric_service.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/widgets/hidden_ai_trigger.dart';
import 'package:community_safety_app/features/incident/presentation/widgets/incident_category_visuals.dart';
import 'package:community_safety_app/core/presentation/neo/aurora_background.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/live_indicator.dart';
import 'package:community_safety_app/core/presentation/neo/neo_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_chip.dart';
import 'package:community_safety_app/core/presentation/neo/neo_dialog.dart';
import 'package:community_safety_app/core/presentation/neo/neo_icon_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_segmented.dart';
import 'package:community_safety_app/core/presentation/neo/neo_surface.dart';
import 'package:community_safety_app/core/presentation/neo/neo_tag.dart';
import 'package:community_safety_app/core/presentation/neo/neo_tray.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_text_field.dart';
import 'package:geolocator/geolocator.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/core/utils/incident_triage_helper.dart';
import 'package:community_safety_app/features/incident/data/datasources/incident_ai_remote_data_source.dart';
import 'package:community_safety_app/features/incident/presentation/pages/incident_detail_page.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';
import 'package:community_safety_app/core/presentation/neo/word_safe_text.dart';

class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  int currentStep = 2;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  final TextEditingController _coordinatesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _victimNameController = TextEditingController();
  final TextEditingController _victimPhoneController = TextEditingController();

  bool _isReportingOnBehalf = false;
  bool _isBlotter = false;
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
      builder: (dialogCtx) => NeoDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeoDialogIcon(
              icon: Icons.warning_amber_rounded,
              color: AppColors.warning,
            ),
            SizedBox(height: 16),
            Text(
              _l10n.reportDiscardTitle,
              textAlign: TextAlign.center,
              style: _dialogTitleStyle,
            ),
            SizedBox(height: 8),
            Text(
              _l10n.reportDiscardMessage,
              textAlign: TextAlign.center,
              style: _dialogBodyStyle,
            ),
            SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: _l10n.reportKeepEditing,
                    variant: NeoButtonVariant.standard,
                    height: 48,
                    expand: true,
                    onPressed: () => Navigator.of(dialogCtx).pop(false),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: NeoButton(
                    label: _l10n.reportDiscard,
                    variant: NeoButtonVariant.emergency,
                    height: 48,
                    expand: true,
                    onPressed: () => Navigator.of(dialogCtx).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  TextStyle get _dialogTitleStyle => TextStyle(
        color: AppColors.textDark,
        fontSize: 19,
        fontWeight: FontWeight.w800,
      );

  TextStyle get _dialogBodyStyle => TextStyle(
        color: AppColors.textLight,
        fontSize: 13.5,
        height: 1.45,
        fontWeight: FontWeight.w500,
      );

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
            content: Text(_l10n.reportGpsPinned(_resolvedAddress!)),
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
          content: Text(e is LocationServiceException
              ? LocalizedLabels.locationError(context, e.code)
              : errorMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 5),
          action: isGpsOff
              ? SnackBarAction(
                  label: _l10n.commonSettings,
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
                ? _l10n.reportEvidencePhotoSynced
                : _l10n.reportPhotoSavedLocally),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isCloud ? AppColors.solved : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (uploadError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.reportImageSavedOffline(uploadError.toString().split(']').last.trim())),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.reportChooseFileFailed('$e')),
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
                ? _l10n.reportPhotoSynced
                : _l10n.reportPhotoSavedLocally),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isCloud ? AppColors.solved : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (uploadError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.reportPhotoSavedOffline(uploadError.toString().split(']').last.trim())),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.reportOpenCameraFailed('$e')),
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
      builder: (ctx) => NeoDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeoDialogIcon(
              icon: Icons.video_file_outlined,
              color: AppColors.danger,
            ),
            SizedBox(height: 16),
            Text(
              _l10n.reportVideoLimitTitle,
              textAlign: TextAlign.center,
              style: _dialogTitleStyle,
            ),
            SizedBox(height: 8),
            Text(
              _l10n.reportVideoLimitMessage(sizeMB.toStringAsFixed(1)),
              textAlign: TextAlign.center,
              style: _dialogBodyStyle,
            ),
            SizedBox(height: 22),
            NeoButton(
              label: _l10n.reportUnderstood,
              expand: true,
              height: 50,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
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
                ? _l10n.reportVideoSynced
                : _l10n.reportVideoSavedLocally),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isCloud ? AppColors.solved : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (uploadError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.reportVideoSavedOffline(uploadError.toString().split(']').last.trim())),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.reportChooseVideoFailed('$e')),
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
                ? _l10n.reportVideoSynced
                : _l10n.reportVideoSavedLocally),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isCloud ? AppColors.solved : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (uploadError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.reportVideoSavedOffline(uploadError.toString().split(']').last.trim())),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.reportRecordVideoFailed('$e')),
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
            _l10n.reportBiometricReason,
      );
      if (!verified) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.reportBiometricCancelled),
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
      isBlotter: _isBlotter &&
          IncidentEntity.isBlotterCategory(_selectedIncidentCategory),
      victimName:
          _isReportingOnBehalf ? _victimNameController.text.trim() : null,
      victimPhone: _isReportingOnBehalf &&
              _victimPhoneController.text.trim().isNotEmpty
          ? _victimPhoneController.text.trim()
          : null,
    );

    // Display the submitting dialog on a dark command-center tray
    _isSubmittingReport = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: NeoTray(
            live: true,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 46,
                  width: 46,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _l10n.reportSubmittingTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  _l10n.reportSubmittingMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: NeoTray.soft,
                    fontSize: 13,
                    height: 1.4,
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
        SnackBar(
          content: Text(_l10n.reportVictimNameRequired),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedIncidentCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.reportCategoryRequired),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedIncidentCategory == 'Other Emergency' &&
        _otherCategoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.reportOtherTypeRequired),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.reportDescriptionRequired),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_isUploadingImage || _isUploadingVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.reportMediaStillUploading),
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
    final accent = isMyOwnReport ? AppColors.primary : AppColors.pending;
    final accentText = AppColors.isDarkMode
        ? Color.lerp(accent, Colors.white, 0.35)!
        : Color.lerp(accent, AppColors.ink, 0.25)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => NeoDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NeoDialogIcon(
                  icon: isMyOwnReport
                      ? Icons.check_circle_outline_rounded
                      : Icons.notifications_active_rounded,
                  color: accent,
                  size: 52,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMyOwnReport
                            ? _l10n.reportDuplicateMineTitle
                            : _l10n.reportDuplicateNearbyTitle,
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        isMyOwnReport
                            ? _l10n.reportDuplicateFiled(
                                LocalizedLabels.relativeTime(context, duplicate.timestamp))
                            : _l10n.reportDuplicateWithin,
                        style: TextStyle(
                          color: accentText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
              padding: const EdgeInsets.all(14),
              decoration: NeoSurface.inset(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IncidentCategoryTile(
                        storedCategory: duplicate.category,
                        size: 38,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocalizedLabels.category(context, duplicate.category),
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.near_me_rounded,
                                    color: AppColors.primaryText, size: 14),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _l10n.reportDistanceFromYou(distanceInMeters.round()),
                                    style: TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isMyOwnReport) ...[
                        SizedBox(width: 8),
                        NeoTag(
                          icon: Icons.person_rounded,
                          label: _l10n.reportYourReport,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    duplicate.description,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.people_alt_rounded,
                          color: AppColors.textLight, size: 14),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _l10n.reportCitizensAffected(duplicate.upvoteCount + 1),
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
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
                  ? _l10n.reportDuplicateMineInfo(
                      LocalizedLabels.status(context, duplicate.status))
                  : _l10n.reportDuplicateCorroborateInfo,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            SizedBox(height: 20),

            // Button 1: Primary Action (View My Report vs Me Too)
            NeoButton(
              label: isMyOwnReport
                  ? _l10n.reportViewMyReport
                  : _l10n.reportMeToo,
              icon: isMyOwnReport
                  ? Icons.assignment_turned_in_rounded
                  : Icons.front_hand_rounded,
              expand: true,
              height: 50,
              onPressed: () {
                Navigator.pop(dialogCtx);
                if (!isMyOwnReport && !hasVoted) {
                  context.read<IncidentBloc>().add(
                        UpvoteIncidentRequested(
                          duplicate.id,
                          currentUserId,
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _l10n.reportCorroborated,
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
            ),
            SizedBox(height: 6),

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
                      ? _l10n.reportSubmitAnyway
                      : _l10n.reportSubmitSeparate,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFileDisplayText() {
    if (_isUploadingImage) {
      return _l10n.reportUploadingImage;
    }
    if (_selectedImageFile == null) {
      return _l10n.reportNoFileChosen;
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
          SnackBar(
            content: Text(_l10n.reportAiTriageEnabled),
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
      builder: (ctx) => NeoDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeoDialogIcon(
              icon: Icons.phone_in_talk_rounded,
              color: AppColors.danger,
            ),
            SizedBox(height: 16),
            Text(
              _l10n.reportCallAgencyTitle(agencyName),
              textAlign: TextAlign.center,
              style: _dialogTitleStyle,
            ),
            SizedBox(height: 8),
            Text(
              _l10n.reportCallAgencyMessage(agencyName, phoneNumber),
              style: _dialogBodyStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: _l10n.commonCancel,
                    variant: NeoButtonVariant.standard,
                    height: 48,
                    expand: true,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: NeoButton(
                    label: _l10n.reportCallNow,
                    icon: Icons.call_rounded,
                    variant: NeoButtonVariant.emergency,
                    height: 48,
                    expand: true,
                    onPressed: () async {
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
                                _l10n.reportDialerFailed(phoneNumber)),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
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
              content: Text(_l10n.reportSubmitFailed(state.message)),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is IncidentTriageLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => NeoDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.secondary),
                  SizedBox(height: 18),
                  Text(
                    _l10n.reportAiAnalyzing,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is IncidentTriageError) {
          Navigator.of(context).pop(); // dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_l10n.reportAiFailed),
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
            builder: (context) => NeoDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NeoDialogIcon(
                    icon: Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _l10n.reportAiAssessmentTitle,
                    textAlign: TextAlign.center,
                    style: _dialogTitleStyle,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${LocalizedLabels.urgency(context, state.triageResult.urgency)} - ${state.triageResult.justification}",
                    textAlign: TextAlign.center,
                    style: _dialogBodyStyle,
                  ),
                  SizedBox(height: 22),
                  Custom3dButton(
                    text: _l10n.reportProceedToSubmit,
                    borderRadius: 999,
                    height: 52,
                    onPressed: () {
                      Navigator.of(context).pop();
                      _executeStandardSubmit(urgencyStatus: state.triageResult.urgency);
                    },
                  ),
                ],
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
          child: AuroraBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          20,
                          8,
                          20,
                          32 + MediaQuery.paddingOf(context).bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildEmergencyHotlinesSection(),
                            SizedBox(height: 18),
                            _buildDetailsCard(),
                            SizedBox(height: 18),
                            _buildLocationCard(),
                            SizedBox(height: 18),
                            _buildEvidenceTray(),
                            SizedBox(height: 24),
                            _buildSubmitButton(state),
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
      },
    );
  }

  TextStyle get _cardTitleStyle => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      );

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          NeoIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: _l10n.commonBack,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          SizedBox(width: 12),
          _buildAppLogo(),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              _l10n.reportTitle,
              maxLines: 2,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                height: 1.15,
              ),
            ),
          ),
          SizedBox(width: 8),
          NeoIconButton(
            icon: Icons.info_outline_rounded,
            tooltip: _l10n.reportGuidelinesTooltip,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_l10n.reportGuidelinesMessage),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyHotlinesSection() {
    return NeoTray(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on_rounded, color: AppColors.dangerLight, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _l10n.reportHotlinesTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final call911 = NeoButton(
                label: _l10n.reportCall911,
                icon: Icons.phone_rounded,
                variant: NeoButtonVariant.emergency,
                height: 48,
                expand: true,
                onPressed: () => _showEmergencyCallConfirmation(
                    _l10n.reportEmergencyHotline, "911"),
              );
              final desk = NeoButton(
                label: _l10n.reportBarangayDesk,
                icon: Icons.shield_outlined,
                variant: NeoButtonVariant.slate,
                height: 48,
                expand: true,
                onPressed: () => _showEmergencyCallConfirmation(
                    _l10n.reportBarangayDesk, "0917-000-0000"),
              );
              // Side by side while both labels fit on one line; stacked on
              // small phones, with longer Filipino labels or large text.
              final half = (constraints.maxWidth - 10) / 2;
              if (call911.fitsOneLine(context, half) &&
                  desk.fitsOneLine(context, half)) {
                return Row(
                  children: [
                    Expanded(child: call911),
                    SizedBox(width: 10),
                    Expanded(child: desk),
                  ],
                );
              }
              return Column(
                children: [call911, SizedBox(height: 10), desk],
              );
            },
          ),
        ],
      ),
    );
  }

  void _selectReportingMode(bool onBehalf) {
    setState(() {
      _isReportingOnBehalf = onBehalf;
    });
    if (onBehalf && (_latitude == null || _latitude == 0.0)) {
      _updatePinnedLocation(
        _defaultMoonwalkCenter.latitude,
        _defaultMoonwalkCenter.longitude,
        animateCamera: true,
        sectorHint: _selectedBarangay,
      );
    }
  }

  Widget _buildDetailsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_l10n.reportDetailsTitle, style: _cardTitleStyle),
          SizedBox(height: 16),

          // ── Reporting Mode Selector: Myself (At Scene) vs. On Behalf ───────
          _fieldLabel(_l10n.reportModeLabel),
          NeoSegmented<bool>(
            segments: [
              NeoSegment(value: false, label: _l10n.reportModeMyself),
              NeoSegment(value: true, label: _l10n.reportModeForSomeone),
            ],
            selected: _isReportingOnBehalf,
            onChanged: _selectReportingMode,
          ),
          SizedBox(height: 16),

          // ── Victim Dossier Form (Active when Reporting on Behalf) ───────────
          if (_isReportingOnBehalf) ...[
            _buildVictimDossier(),
            SizedBox(height: 16),
          ],

          // Complainant Selection
          _fieldLabel(_l10n.reportComplainantLabel),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final userName = authState is Authenticated
                  ? (authState.user.fullName ??
                      (authState.user.email.isNotEmpty
                          ? authState.user.email.split('@').first
                          : _l10n.commonResident))
                  : _l10n.commonResident;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  NeoChip(
                    label: _l10n.reportComplainantSelf(userName),
                    icon: Icons.person_rounded,
                    selected: _selectedComplainant == "self",
                    onPressed: () => setState(() => _selectedComplainant = "self"),
                  ),
                  NeoChip(
                    label: _l10n.reportComplainantAnonymous,
                    icon: Icons.security_rounded,
                    selected: _selectedComplainant == "anonymous",
                    onPressed: () =>
                        setState(() => _selectedComplainant = "anonymous"),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 18),

          // Incident Category Selection
          _fieldLabel(_l10n.reportCategoryLabel),
          _buildCategoryGrid(),
          SizedBox(height: 16),

          // Blotter entry: only for disputes and complaints the barangay records
          if (IncidentEntity.isBlotterCategory(_selectedIncidentCategory)) ...[
            _buildBlotterToggle(),
            SizedBox(height: 16),
          ],

          if (_selectedIncidentCategory == 'Other Emergency')
            Custom3dTextField(
              controller: _otherCategoryController,
              labelText: _l10n.reportOtherTypeLabel,
              hintText: _l10n.reportOtherTypeHint,
              prefixIcon: Icons.emergency_outlined,
              inset: true,
            ),

          // Description 3D text field
          Custom3dTextField(
            controller: _descriptionController,
            labelText: _l10n.reportDescriptionLabel,
            hintText: _l10n.reportDescriptionHint,
            prefixIcon: Icons.description_outlined,
            maxLines: 4,
            inset: true,
          ),
        ],
      ),
    );
  }

  Widget _buildVictimDossier() {
    final isDark = AppColors.isDarkMode;
    final accent = isDark
        ? Color.lerp(AppColors.onBehalf, Colors.white, 0.4)!
        : AppColors.onBehalf;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      decoration: BoxDecoration(
        color: AppColors.onBehalf.withValues(alpha: isDark ? 0.14 : 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.onBehalf.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency_share_rounded, size: 18, color: accent),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _l10n.reportForSomeoneTitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            _l10n.reportForSomeoneHelp,
            style: TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.4),
          ),
          SizedBox(height: 12),
          Custom3dTextField(
            controller: _victimNameController,
            labelText: _l10n.reportVictimNameLabel,
            hintText: _l10n.reportVictimNameHint,
            prefixIcon: Icons.person_rounded,
            inset: true,
          ),
          Custom3dTextField(
            controller: _victimPhoneController,
            labelText: _l10n.reportVictimPhoneLabel,
            hintText: _l10n.reportVictimPhoneHint,
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            inset: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBlotterToggle() {
    final isDark = AppColors.isDarkMode;
    final accent = isDark
        ? Color.lerp(AppColors.blotter, Colors.white, 0.4)!
        : AppColors.blotter;
    // One control for screen readers: the title, help text and switch.
    return MergeSemantics(
      child: GestureDetector(
        onTap: () => setState(() => _isBlotter = !_isBlotter),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            color: AppColors.blotter.withValues(alpha: isDark ? 0.14 : 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.blotter.withValues(alpha: _isBlotter ? 0.7 : 0.35),
              width: _isBlotter ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.gavel_rounded, size: 18, color: accent),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WordSafeText(
                      _l10n.reportBlotterTitle,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _l10n.reportBlotterHelp,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                key: const Key('reportBlotterSwitch'),
                value: _isBlotter,
                activeThumbColor: AppColors.blotter,
                onChanged: (value) => setState(() => _isBlotter = value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Two categories per row; both tiles in a row share the taller height.
  Widget _buildCategoryGrid() {
    final rows = <Widget>[];
    for (var i = 0; i < _incidentCategories.length; i += 2) {
      final first = _incidentCategories[i];
      final second =
          i + 1 < _incidentCategories.length ? _incidentCategories[i + 1] : null;
      rows.add(Padding(
        padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildCategoryTile(first)),
              SizedBox(width: 10),
              Expanded(
                child: second == null ? SizedBox() : _buildCategoryTile(second),
              ),
            ],
          ),
        ),
      ));
    }
    return Column(children: rows);
  }

  Widget _buildCategoryTile(String category) {
    return _CategoryTile(
      storedCategory: category,
      label: LocalizedLabels.category(context, category),
      selected: _selectedIncidentCategory == category,
      onTap: () {
        setState(() {
          _selectedIncidentCategory = category;
          if (!IncidentEntity.isBlotterCategory(category)) _isBlotter = false;
        });
      },
    );
  }

  Widget _buildLocationCard() {
    final pinColor = _latitude != null
        ? (_isReportingOnBehalf ? AppColors.onBehalf : AppColors.solved)
        : AppColors.primary;
    final mapAccent =
        _isReportingOnBehalf ? AppColors.onBehalf : AppColors.primary;
    final guideAccent =
        _isReportingOnBehalf ? const Color(0xFFFDBA74) : AppColors.secondary;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Real GPS / Interactive Location Section ────────────────────────
          Text(
            _isReportingOnBehalf ? _l10n.reportLocationVictimTitle : _l10n.reportLocationTitle,
            style: _cardTitleStyle,
          ),
          SizedBox(height: 14),

          // Pinned Location Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: NeoSurface.inset(radius: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: pinColor.withValues(alpha: AppColors.isDarkMode ? 0.22 : 0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _latitude != null
                        ? Icons.pin_drop_rounded
                        : Icons.location_searching_rounded,
                    color: AppColors.isDarkMode
                        ? Color.lerp(pinColor, Colors.white, 0.35)
                        : pinColor,
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
                              _resolvedAddress ?? _l10n.reportLocationNotPinned,
                              style: TextStyle(
                                color: _resolvedAddress != null ? AppColors.textDark : AppColors.textLight,
                                fontSize: 13.5,
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
                            ? _l10n.reportCoordinates(
                                "${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}${_resolvedSector != null ? ' • $_resolvedSector' : ''}")
                            : _l10n.reportPinHint,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // ── Interactive Draggable Pin Google Map ───────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: mapAccent.withValues(alpha: 0.5),
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
                    style: MapStyles.current,
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
                          title: _isReportingOnBehalf ? _l10n.reportVictimLocation : _l10n.reportLocationTitle,
                          snippet: _resolvedAddress ?? _l10n.reportDragToRefine,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.ink.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _isDraggingPin ? guideAccent : Colors.white12,
                          width: _isDraggingPin ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isDraggingPin ? Icons.open_with_rounded : Icons.touch_app_rounded,
                            size: 14,
                            color: guideAccent,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _isDraggingPin
                                  ? _l10n.reportDraggingPin
                                  : (_isReverseGeocoding
                                      ? _l10n.reportResolvingSector
                                      : _l10n.reportMapHint),
                              style: TextStyle(
                                fontSize: 10.5,
                                color: _isDraggingPin ? guideAccent : Colors.white,
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
                      foregroundColor: AppColors.primaryText,
                      elevation: 3,
                      shape: const CircleBorder(),
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
          NeoButton(
            label: _isLocating
                ? _l10n.reportAcquiringGps
                : (_latitude != null ? _l10n.reportUsePhoneGps : _l10n.reportPinWithGps),
            icon: _latitude != null ? Icons.refresh_rounded : Icons.my_location_rounded,
            variant: _latitude != null ? NeoButtonVariant.standard : NeoButtonVariant.primary,
            expand: true,
            height: 48,
            onPressed: _isLocating ? null : _getCurrentLocation,
          ),
          SizedBox(height: 16),

          // Landmark Note Input
          Custom3dTextField(
            controller: _landmarkController,
            labelText: _l10n.reportLandmarkLabel,
            hintText: _l10n.reportLandmarkHint,
            prefixIcon: Icons.add_location_alt_outlined,
            inset: true,
          ),
        ],
      ),
    );
  }

  // Photo and video evidence on a dark tray: camera buttons on the left,
  // pick-a-file buttons beside them.
  Widget _buildEvidenceTray() {
    return NeoTray(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              NeoIconButton(
                icon: Icons.photo_camera_rounded,
                tooltip: _l10n.reportTakePhoto,
                tone: NeoIconButtonTone.slate,
                size: 48,
                onPressed: _isUploadingImage ? null : _takeEvidencePhoto,
              ),
              SizedBox(width: 10),
              Expanded(
                child: NeoButton(
                  label: _getFileDisplayText(),
                  icon: Icons.photo_library_rounded,
                  variant: NeoButtonVariant.slate,
                  height: 48,
                  expand: true,
                  onPressed: _isUploadingImage ? null : _chooseEvidenceFile,
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
                  // Image.file can't read files on web; there the path is a blob: URL.
                  child: kIsWeb
                      ? Image.network(
                          _selectedImageFile!.path,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
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
                        color: AppColors.ink.withValues(alpha: 0.7),
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
                        child: CircularProgressIndicator(color: AppColors.secondary),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          SizedBox(height: 10),

          // Video Evidence Section (Low Latency / Max 20MB / 30s)
          Row(
            children: [
              NeoIconButton(
                icon: Icons.videocam_rounded,
                tooltip: _l10n.reportRecordVideo,
                tone: NeoIconButtonTone.slate,
                size: 48,
                onPressed: _isUploadingVideo ? null : _recordEvidenceVideo,
              ),
              SizedBox(width: 10),
              Expanded(
                child: NeoButton(
                  label: _isUploadingVideo
                      ? _l10n.reportUploadingVideo
                      : (_selectedVideoFile == null ? _l10n.reportAddVideo : _l10n.reportChangeVideo),
                  icon: Icons.video_library_rounded,
                  variant: NeoButtonVariant.slate,
                  height: 48,
                  expand: true,
                  onPressed: _isUploadingVideo ? null : _chooseVideoFile,
                ),
              ),
            ],
          ),

          if (_selectedVideoFile != null) ...[
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.videocam_rounded, color: AppColors.secondary, size: 20),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedVideoFile!.path.split('/').last.split('\\').last,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          _l10n.reportVideoVerified(_selectedVideoSizeMB.toStringAsFixed(1)),
                          style: TextStyle(
                            color: AppColors.secondaryLight,
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
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.close, color: NeoTray.soft, size: 18),
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
        ],
      ),
    );
  }

  Widget _buildSubmitButton(IncidentState state) {
    // 3D Submit Button
    if (state is IncidentSubmitLoading || state is IncidentTriageLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return Custom3dButton(
      icon: Icons.send_rounded,
      text: _l10n.reportSubmitButton,
      gradient: AppColors.emergencyGradient,
      borderRadius: 999,
      height: 58,
      onPressed: _submitReport,
    );
  }

  List<String> _getSafetyGuidelines(String category) {
    switch (category) {
      case "Fire Incident":
        return [
          _l10n.reportTipFire1,
          _l10n.reportTipFire2,
          _l10n.reportTipFire3,
          _l10n.reportTipFire4,
          _l10n.reportTipFire5,
          _l10n.reportTipFire6,
        ];
      case "Theft / Robbery":
        return [
          _l10n.reportTipTheft1,
          _l10n.reportTipTheft2,
          _l10n.reportTipTheft3,
          _l10n.reportTipTheft4,
        ];
      case "Medical Emergency":
        return [
          _l10n.reportTipMedical1,
          _l10n.reportTipMedical2,
          _l10n.reportTipMedical3,
        ];
      case "Road Accident":
        return [
          _l10n.reportTipRoad1,
          _l10n.reportTipRoad2,
          _l10n.reportTipRoad3,
        ];
      default:
        return [
          _l10n.reportTipGeneral1,
          _l10n.reportTipGeneral2,
          _l10n.reportTipGeneral3,
          _l10n.reportTipGeneral4,
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
          categoryIcon: IncidentCategoryVisual.of(category).icon,
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

  AppLocalizations get _l10n => AppLocalizations.of(context);

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
          _l10n.reportPriorityCritical,
          _l10n.reportPriorityCriticalDetail,
        );
      case 'HIGH':
        return (
          const Color(0xFFEA580C), // Orange · high priority
          Icons.error_outline_rounded,
          _l10n.reportPriorityHigh,
          _l10n.reportPriorityHighDetail,
        );
      case 'MEDIUM':
        return (
          AppColors.primary,
          Icons.info_outline_rounded,
          _l10n.reportPriorityMedium,
          _l10n.reportPriorityMediumDetail,
        );
      case 'LOW':
      default:
        return (
          AppColors.solved,
          Icons.check_circle_outline_rounded,
          _l10n.reportPriorityStandard,
          _l10n.reportPriorityStandardDetail,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (urgencyColor, urgencyIcon, urgencyTitle, urgencySubtitle) =
        _getUrgencyVisuals(widget.urgency);
    final isDark = AppColors.isDarkMode;
    final urgencyText = isDark
        ? Color.lerp(urgencyColor, Colors.white, 0.35)!
        : Color.lerp(urgencyColor, AppColors.ink, 0.3)!;
    final adviceAccent =
        isDark ? AppColors.secondaryLight : const Color(0xFF0E7490);
    final measures =
        _aiMeasures.isNotEmpty ? _aiMeasures : widget.fallbackGuidelines;

    return NeoDialog(
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: dispatched, the category and the assessed badge
              const LiveIndicator.ring(
                size: 74,
                child: Icon(Icons.check_rounded),
              ),
              SizedBox(height: 16),
              Text(
                _l10n.reportDispatchedTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.categoryIcon, size: 16, color: AppColors.textLight),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      LocalizedLabels.category(context, widget.category),
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _l10n.reportAssessedBadge,
                  style: TextStyle(
                    color: AppColors.secondaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 18),

              // Dynamic Assessed Priority Card (Replacing static "Pending Evaluation")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: isDark ? 0.16 : 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: urgencyColor.withValues(alpha: 0.45), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            urgencyColor,
                            Color.lerp(urgencyColor, AppColors.ink, 0.25)!,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: urgencyColor.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(urgencyIcon, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            urgencyTitle,
                            style: TextStyle(
                              color: urgencyText,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            urgencySubtitle,
                            style: TextStyle(
                              color: AppColors.textDark.withValues(alpha: 0.8),
                              fontSize: 12.5,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14),

              // Gemini AI Precautionary Advisory Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFF1E2D50).withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: adviceAccent,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _l10n.reportAiSafetyAdvice,
                            style: TextStyle(
                              color: adviceAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Gemini 3.5",
                            style: TextStyle(
                              color: adviceAccent,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    if (_isLoadingAi)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.secondary,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _l10n.reportAiGenerating,
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      for (var i = 0; i < measures.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 22,
                                child: Text(
                                  '${i + 1}.',
                                  style: TextStyle(
                                    color: adviceAccent,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  measures[i],
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 13.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Action Button
              NeoButton(
                label: _l10n.reportUnderstoodDone,
                expand: true,
                height: 54,
                onPressed: widget.onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One incident category in the Report Incident grid: its icon and name on
/// a raised tile, ringed in blue when selected.
class _CategoryTile extends StatelessWidget {
  final String storedCategory;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.storedCategory,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    final visual = IncidentCategoryVisual.of(storedCategory);
    final radius = BorderRadius.circular(18);

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: selected
                ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.24)
                    : const Color(0xFFEFF4FF))
                : null,
            gradient: selected
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? const [Color(0xFF26334F), Color(0xFF1C2742)]
                        : const [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
                  ),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.glassBorder,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : const Color(0xFF1E2D50).withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Icon(visual.icon, size: 19, color: visual.foreground),
              SizedBox(width: 8),
              Expanded(
                child: WordSafeText(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    color: selected
                        ? (isDark ? AppColors.primaryText : AppColors.deepBlue)
                        : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
