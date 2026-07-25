import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_color.dart';
import '../widgets/custom_3d_button.dart';
import '../widgets/custom_3d_card.dart';
import '../widgets/custom_3d_text_field.dart';
import '../admin/models/incident_report.dart';
import '../services/mock_database_service.dart';

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
  late final String _currentUserName;
  String _selectedBarangay = "Area 1";

  String? _selectedIncidentCategory;
  String _selectedUrgencyLevel = "Medium Emergency";

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

  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedEvidenceFiles = [];
  bool _addAnotherFile = false;

  @override
  void initState() {
    super.initState();
    _currentUserName = MockDatabaseService().currentUser?.name ?? "Anonymous";
    _selectedComplainant = _currentUserName;
  }

  @override
  void dispose() {
    _coordinatesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getUrgencyLevelByCategory(String category) {
    switch (category) {
      case "Fire Incident":
      case "Medical Emergency":
      case "Violence / Physical Fight":
      case "Road Accident":
        return "High Emergency";

      case "Theft / Robbery":
      case "Suspicious Activity":
      case "Flood / Calamity":
      case "Lost Item / Missing Person":
      case "Other Emergency":
        return "Medium Emergency";

      case "Noise Complaint":
        return "Low Emergency";

      default:
        return "Medium Emergency";
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case "High Emergency":
        return AppColors.danger;
      case "Medium Emergency":
        return AppColors.pending;
      case "Low Emergency":
        return AppColors.solved;
      default:
        return AppColors.textLight;
    }
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
          "Do not touch possible evidence in the area.",
          "Wait for responders and provide clear information.",
        ];

      case "Medical Emergency":
        return [
          "Call an ambulance or emergency hotline immediately.",
          "Keep the patient calm and do not move them unless the area is unsafe.",
          "Check if the person is breathing and responsive.",
          "If bleeding, apply gentle pressure using clean cloth.",
          "Do not give food, water, or medicine unless advised by a medical professional.",
          "Prepare important information: age, symptoms, allergies, and location.",
        ];

      case "Violence / Physical Fight":
        return [
          "Do not join or physically stop the fight if it is unsafe.",
          "Move away from the violent area and protect yourself first.",
          "Call barangay responders or police immediately.",
          "If possible, guide other people away from the scene.",
          "Remember important details like number of people involved and weapons seen.",
          "Wait for authorities and avoid spreading unverified information.",
        ];

      case "Road Accident":
        return [
          "Move to a safe side of the road if you are not injured.",
          "Do not move injured persons unless there is immediate danger.",
          "Call emergency responders or ambulance immediately.",
          "Turn on hazard lights or warn incoming vehicles if safe.",
          "Take note of vehicle plate numbers and accident location.",
          "Stay calm and wait for responders to arrive.",
        ];

      case "Suspicious Activity":
        return [
          "Do not confront the suspicious person directly.",
          "Stay in a safe area and keep distance.",
          "Observe details such as location, clothing, direction, and behavior.",
          "Report to barangay or police immediately.",
          "Avoid posting or accusing someone publicly without confirmation.",
          "Wait for authorities to verify the situation.",
        ];

      case "Flood / Calamity":
        return [
          "Move to higher ground immediately.",
          "Avoid walking or driving through floodwater.",
          "Turn off electricity if safe before leaving the area.",
          "Prepare emergency items like flashlight, water, phone, and medicine.",
          "Stay updated through official barangay or government announcements.",
          "Call responders if someone is trapped or in danger.",
        ];

      case "Lost Item / Missing Person":
        return [
          "Stay calm and remember the last known location.",
          "Contact nearby barangay desk, police, or security personnel.",
          "Provide a clear description, photo, clothing, and last seen details.",
          "Do not spread incomplete information online without verification.",
          "Check nearby CCTV areas or establishments if possible.",
          "Keep your phone open for updates from responders.",
        ];

      case "Noise Complaint":
        return [
          "Avoid direct confrontation if it may lead to conflict.",
          "Record the time, location, and type of noise if needed.",
          "Report calmly to the barangay desk or proper authority.",
          "Stay indoors if the situation feels unsafe.",
          "Wait for barangay personnel to handle the concern.",
        ];

      default:
        return [
          "Move to a safe location first.",
          "Call the proper emergency hotline if there is immediate danger.",
          "Avoid touching evidence or confronting involved persons.",
          "Provide accurate details to responders.",
          "Stay calm and wait for official assistance.",
        ];
    }
  }

  Future<void> _chooseEvidenceFile() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() {
        if (_addAnotherFile) {
          _selectedEvidenceFiles.add(pickedFile);
        } else {
          _selectedEvidenceFiles.clear();
          _selectedEvidenceFiles.add(pickedFile);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to choose file: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _takeEvidencePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() {
        if (_addAnotherFile) {
          _selectedEvidenceFiles.add(pickedFile);
        } else {
          _selectedEvidenceFiles.clear();
          _selectedEvidenceFiles.add(pickedFile);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to open camera: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getFileDisplayText() {
    if (_selectedEvidenceFiles.isEmpty) {
      return "No file chosen";
    }

    if (_selectedEvidenceFiles.length == 1) {
      return _selectedEvidenceFiles.first.name;
    }

    return "${_selectedEvidenceFiles.length} files selected";
  }

  Widget _buildAppLogo() {
    return SizedBox(
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

  void _showPostSubmitSafetyWindow() {
    final String category = _selectedIncidentCategory ?? "Other Emergency";
    final List<String> guidelines = _getSafetyGuidelines(category);
    final Color urgencyColor = _getUrgencyColor(_selectedUrgencyLevel);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: urgencyColor.withValues(alpha: 0.3)),
          ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: urgencyColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: urgencyColor,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: urgencyColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: urgencyColor.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.priority_high_rounded,
                          color: urgencyColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Priority Level:",
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedUrgencyLevel,
                            style: TextStyle(
                              color: urgencyColor,
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

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Text(
                      "Reminder: If there is immediate danger, call emergency responders right away. The report helps the admin monitor and prioritize the incident, but emergency hotlines should still be contacted for urgent situations.",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 12.5,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showEmergencyCallConfirmation(
                            "Emergency Hotline", "911");
                      },
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
                              Icon(Icons.phone_in_talk,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text(
                                "Call 911",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
        );
      },
    );
  }

  void _submitReport() {
    if (_selectedIncidentCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select an incident category before submitting.",
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.send_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "Submitting $_selectedIncidentCategory report...",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        duration: const Duration(milliseconds: 900),
      ),
    );

    final newReport = IncidentReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      incidentType: _selectedIncidentCategory!,
      reporterName: _selectedComplainant,
      location: _selectedBarangay,
      date: DateTime.now(),
      status: IncidentStatus.pending,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : "No description provided",
      urgencyLevel: _selectedUrgencyLevel,
    );
    MockDatabaseService().addReport(newReport);

    Future.delayed(const Duration(milliseconds: 950), () {
      if (!mounted) return;
      _showPostSubmitSafetyWindow();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            _buildPrimaryFormContainer(),
          ],
        ),
      ),
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

  Widget _buildPrimaryFormContainer() {
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
            ),
            items: [
              DropdownMenuItem(value: _currentUserName, child: Text("Self: $_currentUserName")),
              const DropdownMenuItem(value: "Anonymous", child: Text("Anonymous")),
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
                if (val != null) {
                  _selectedUrgencyLevel = _getUrgencyLevelByCategory(val);
                }
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
                  onPressed: _chooseEvidenceFile,
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
                  onPressed: _takeEvidencePhoto,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3D Submit Button
          Custom3dButton(
            icon: Icons.send_rounded,
            text: "SUBMIT INCIDENT REPORT",
            onPressed: _submitReport,
          ),
        ],
      ),
    );
  }
}
