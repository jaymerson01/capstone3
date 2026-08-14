import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/location_service.dart';
import 'package:community_safety_app/core/services/camera_service.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/widgets/hidden_ai_trigger.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_text_field.dart';

class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  int currentStep = 2;

  final TextEditingController _coordinatesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedComplainant = "Anonymous";
  String _selectedBarangay = "Area 1";
  
  bool isAiTriageEnabled = false;

  String? _selectedIncidentCategory;
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
  bool _isLocating = false;

  @override
  void dispose() {
    _coordinatesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });
    try {
      final locationService = sl<LocationService>();
      final coordinate = await locationService.getCurrentLocation();
      if (coordinate != null) {
        setState(() {
          _latitude = coordinate.latitude;
          _longitude = coordinate.longitude;
          _coordinatesController.text =
              "${coordinate.latitude.toStringAsFixed(6)}, ${coordinate.longitude.toStringAsFixed(6)}";
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location pinned successfully!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.solved,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to fetch location: permissions denied or GPS disabled"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching location: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      setState(() {
        _isLocating = false;
      });
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

      final url = await sl<CameraService>().uploadImage(file);
      setState(() {
        _photoUrl = url;
      });
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

      final url = await sl<CameraService>().uploadImage(file);
      setState(() {
        _photoUrl = url;
      });
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

  void _executeStandardSubmit({String urgencyStatus = 'PENDING'}) {
    final double lat = _latitude ?? 0.0;
    final double lng = _longitude ?? 0.0;

    final incident = IncidentEntity(
      id: '',
      reporterId: _selectedComplainant == 'Anonymous' ? 'anonymous' : 'user123',
      category: _selectedIncidentCategory ?? 'Unknown Incident',
      description: _descriptionController.text.trim(),
      latitude: lat,
      longitude: lng,
      photoUrl: _photoUrl,
      status: 'Pending',
      urgencyStatus: urgencyStatus,
      timestamp: DateTime.now(),
    );

    context.read<IncidentBloc>().add(SubmitIncidentReportRequested(incident));
  }

  void _submitReport() {
    if (_selectedIncidentCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an incident category before submitting."),
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

    if (isAiTriageEnabled) {
      context.read<IncidentBloc>().add(AnalyzeIncidentNarrativeEvent(description));
    } else {
      _executeStandardSubmit();
    }
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
                const Icon(Icons.security, size: 18, color: AppColors.primary),
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
                child: const Icon(Icons.phone_in_talk_rounded,
                    color: AppColors.danger, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                'Call $agencyName?',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dial the official hotline for $agencyName ($phoneNumber) now?',
                style: const TextStyle(
                    color: AppColors.textLight, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
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
                        child: const Center(
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.call,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Connecting to $agencyName ($phoneNumber)...',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.surface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color:
                                      AppColors.danger.withValues(alpha: 0.3)),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: AppColors.emergencyGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppColors.dangerGlowShadow,
                        ),
                        child: const Center(
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
          _showPostSubmitSafetyWindow();
        } else if (state is IncidentSubmitFailure) {
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
                    const SizedBox(height: 16),
                    const Text("Gemini AI is analyzing incident threat levels...",
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.primary)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("AI Urgency Assessment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    Text("${state.triageResult.urgency} - ${state.triageResult.justification}", style: const TextStyle(fontSize: 14, color: AppColors.textLight)),
                    const SizedBox(height: 20),
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
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                boxShadow: AppColors.primaryGlowShadow,
              ),
            ),
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            titleSpacing: 0,
            elevation: 0,
            title: Row(
              children: [
                _buildAppLogo(),
                const SizedBox(width: 12),
                const Text(
                  "Report Incident",
                  style: TextStyle(
                    color: Colors.white,
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
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.help_outline,
                        color: Colors.white, size: 20),
                    tooltip: "Filing Guidelines",
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              "Ensure accurate data for priority responder handling."),
                          backgroundColor: AppColors.surface,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.border),
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
                const SizedBox(height: 20),
                _buildPrimaryFormContainer(state),
              ],
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
                child: const Icon(
                  Icons.flash_on,
                  color: AppColors.danger,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
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
          const SizedBox(height: 14),
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
                    child: const Center(
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
              const SizedBox(width: 10),
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
                    child: const Center(
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
          const Text(
            "Incident Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 18),

          // Complainant Selection
          const Text(
            "Complainant Name",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedComplainant,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.accentBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
            items: const [
              DropdownMenuItem(value: "User Profile", child: Text("Self: User Profile")),
              DropdownMenuItem(value: "Anonymous", child: Text("Anonymous")),
            ],
            onChanged: (val) => setState(() => _selectedComplainant = val ?? "Anonymous"),
          ),

          const SizedBox(height: 16),

          // Barangay / Area Selection
          const Text(
            "Barangay Area",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedBarangay,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.accentBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
            items: const [
              DropdownMenuItem(value: "Area 1", child: Text("Area 1 - San Jose")),
              DropdownMenuItem(value: "Area 2", child: Text("Area 2 - Santo Nino")),
              DropdownMenuItem(value: "Area 3", child: Text("Area 3 - Santa Cruz")),
              DropdownMenuItem(value: "Area 4", child: Text("Area 4 - Moonwalk Core")),
            ],
            onChanged: (val) => setState(() => _selectedBarangay = val ?? "Area 1"),
          ),

          const SizedBox(height: 16),
          
          // Coordinate TextField and Pin button
          const Text(
            "Location Context",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Custom3dTextField(
            controller: _coordinatesController,
            labelText: "Location Coordinates (Optional)",
            hintText: "E.g. 14.599512, 120.984222",
            prefixIcon: Icons.gps_fixed,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Colors.white,
              ),
              onPressed: _isLocating ? null : _getCurrentLocation,
              icon: _isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(Icons.map_outlined, size: 16),
              label: Text(
                _isLocating ? "Fetching location..." : "Pin Exact Location",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Incident Category Selection
          const Text(
            "Incident Category",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedIncidentCategory,
            hint: const Text("Select Category"),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.accentBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
            items: _incidentCategories.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(cat), size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(cat),
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

          const SizedBox(height: 16),

          // Description 3D text field
          Custom3dTextField(
            controller: _descriptionController,
            labelText: "Incident Description",
            hintText: "Provide details of what happened, people involved, etc.",
            prefixIcon: Icons.description_outlined,
            maxLines: 4,
          ),

          const SizedBox(height: 12),

          // Evidence Attachment Button
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isUploadingImage ? null : _chooseEvidenceFile,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_getFileDisplayText(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  onPressed: _isUploadingImage ? null : _takeEvidencePhoto,
                ),
              ),
            ],
          ),
          
          if (_selectedImageFile != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                _selectedImageFile!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 3D Submit Button
          if (state is IncidentSubmitLoading || state is IncidentTriageLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primary))
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

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case "HIGH":
      case "High Emergency":
        return AppColors.danger;
      case "MEDIUM":
      case "Medium Emergency":
        return AppColors.pending;
      case "LOW":
      case "Low Emergency":
        return AppColors.solved;
      default:
        return AppColors.primary;
    }
  }

  void _showPostSubmitSafetyWindow() {
    final String category = _selectedIncidentCategory ?? "Other Emergency";
    final List<String> guidelines = _getSafetyGuidelines(category);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          _getCategoryIcon(category),
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Report Submitted",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.pending.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.pending.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology_outlined, color: AppColors.pending, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Priority Level: Pending Evaluation",
                            style: TextStyle(
                              color: AppColors.pending,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "What should you do now?",
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: guidelines.asMap().entries.map((entry) {
                      final int index = entry.key + 1;
                      final String text = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 24,
                              width: 24,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  index.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                text,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: AppColors.primaryGlowShadow,
                            ),
                            child: const Center(
                              child: Text(
                                "I Understand",
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
      },
    );
  }
}
