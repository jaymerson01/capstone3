import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_color.dart';
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

  @override
  void initState() {
    super.initState();
    _currentUserName = MockDatabaseService().currentUser?.name ?? "Anonymous";
    _selectedComplainant = _currentUserName;
  }
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
        return Colors.orange;
      case "Low Emergency":
        return Colors.green;
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
              const Icon(Icons.security, size: 18, color: AppColors.darkGreen),
        ),
      ),
    );
  }

  void _showEmergencyCallConfirmation(String agencyName, String phoneNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('Call $agencyName?')),
            ],
          ),
          content: Text(
            'Are you sure you want to dial the official hotline for $agencyName ($phoneNumber) now?',
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textLight),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Connecting to $agencyName hotline ($phoneNumber)...',
                    ),
                    backgroundColor: AppColors.darkGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'Call Now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 650),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
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
                          color: urgencyColor.withOpacity(0.12),
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
                                color: AppColors.darkGreen,
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
                      color: urgencyColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: urgencyColor.withOpacity(0.35)),
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
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 24,
                              width: 24,
                              decoration: const BoxDecoration(
                                color: AppColors.darkGreen,
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
                      color: AppColors.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withOpacity(0.25),
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
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showEmergencyCallConfirmation(
                              "Emergency Hotline",
                              "911",
                            );
                          },
                          icon: const Icon(Icons.phone_in_talk, size: 18),
                          label: const Text(
                            "Call 911",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "I Understand",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "Submitting $_selectedIncidentCategory report with $_selectedUrgencyLevel level...",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.darkGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );

    final newReport = IncidentReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      incidentType: _selectedIncidentCategory!,
      reporterName: _selectedComplainant ?? MockDatabaseService().currentUser?.name ?? "Anonymous",
      location: _selectedBarangay ?? "Unknown Area",
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
        backgroundColor: AppColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        elevation: 1,
        title: Row(
          children: [
            _buildAppLogo(),
            const SizedBox(width: 12),
            const Text(
              "Report Incident",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 24,
              ),
              tooltip: "Filing Guidelines",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Ensure accurate data for priority responder handling.",
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmergencyHotlinesSection(),
            const SizedBox(height: 24),
            _buildStepperProgressHeader(),
            const SizedBox(height: 24),
            _buildPrimaryFormContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyHotlinesSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: AppColors.danger,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Immediate Threat? Emergency Hotlines",
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final buttonWidth = (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildHotlineButton(
                    "Call Police",
                    Icons.local_police,
                    "911",
                    buttonWidth,
                  ),
                  _buildHotlineButton(
                    "Fire Station",
                    Icons.local_fire_department,
                    "112",
                    buttonWidth,
                  ),
                  _buildHotlineButton(
                    "Ambulance / Med",
                    Icons.medical_services,
                    "143",
                    buttonWidth,
                  ),
                  _buildHotlineButton(
                    "Barangay Desk",
                    Icons.phone_in_talk,
                    "888-9999",
                    buttonWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHotlineButton(
    String name,
    IconData icon,
    String dialNum,
    double targetWidth,
  ) {
    return SizedBox(
      width: targetWidth,
      height: 44,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: BorderSide(
            color: AppColors.danger.withOpacity(0.5),
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: () => _showEmergencyCallConfirmation(name, dialNum),
        icon: Icon(icon, size: 16, color: AppColors.danger),
        label: Text(
          name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildStepperProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Report Submission Process",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Step 2 of 4",
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStepperDot(1, "Info", true),
              _buildStepperLine(true),
              _buildStepperDot(2, "Location", true),
              _buildStepperLine(false),
              _buildStepperDot(3, "Evidence", false),
              _buildStepperLine(false),
              _buildStepperDot(4, "Details", false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperDot(int step, String label, bool isCompletedOrActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompletedOrActive ? AppColors.darkGreen : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompletedOrActive
                  ? AppColors.darkGreen
                  : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: isCompletedOrActive
                ? [
                    BoxShadow(
                      color: AppColors.darkGreen.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompletedOrActive
                ? const Icon(Icons.check, size: 15, color: Colors.white)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isCompletedOrActive
                ? AppColors.textDark
                : AppColors.textLight,
            fontSize: 11,
            fontWeight: isCompletedOrActive
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepperLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2.5,
        color: isActive ? AppColors.darkGreen : Colors.grey.shade200,
        margin: const EdgeInsets.only(bottom: 22),
      ),
    );
  }

  Widget _buildPrimaryFormContainer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Incident Details",
              style: TextStyle(
                color: AppColors.darkGreen,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildIncidentCategorySection(),
          const SizedBox(height: 28),
          _buildSectionTitle(Icons.person_outline, "Reporter Information"),
          const SizedBox(height: 14),
          _buildDropdownBox(
            label: "Complainant Name",
            value: _selectedComplainant,
            options: [
              _currentUserName,
              if (_currentUserName != "Anonymous") "Anonymous",
            ],
            onChanged: (val) => setState(() => _selectedComplainant = val!),
          ),
          const SizedBox(height: 28),
          _buildSectionTitle(Icons.location_on_outlined, "Location Context"),
          const SizedBox(height: 14),
          _buildDropdownBox(
            label: "Barangay",
            value: _selectedBarangay,
            options: ["Area 1", "Area 2", "Area 3", "Area 4", "Area 5"],
            onChanged: (val) => setState(() => _selectedBarangay = val!),
          ),
          const SizedBox(height: 14),
          _buildTextFieldBox(
            hint: "Location Coordinates (Optional)",
            icon: Icons.gps_fixed,
            controller: _coordinatesController,
          ),
          const SizedBox(height: 16),
          _buildMapActionTemplate(
            Icons.map_outlined,
            "Pin Exact Location on System Map",
          ),
          const SizedBox(height: 28),
          _buildSectionTitle(Icons.attach_file_outlined, "Evidence Attachment"),
          const SizedBox(height: 14),
          _buildClassicFileUploadBox(),
          const SizedBox(height: 28),
          _buildSectionTitle(
            Icons.description_outlined,
            "Incident Description",
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 500,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText:
                  "Please describe the incident timeline, visible hazards, or actors involved in clean detail...",
              hintStyle: const TextStyle(
                color: AppColors.textLight,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.darkGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: AppColors.darkGreen.withOpacity(0.4),
              ),
              onPressed: _submitReport,
              child: const Text(
                "Submit Report",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.category_outlined, "Incident Category"),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _selectedIncidentCategory,
          style: const TextStyle(color: AppColors.textDark, fontSize: 14),
          decoration: InputDecoration(
            labelText: "Select Incident Category",
            labelStyle: const TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.darkGreen,
                width: 1.5,
              ),
            ),
          ),
          hint: const Text("Choose the type of incident"),
          items: _incidentCategories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedIncidentCategory = value;
              _selectedUrgencyLevel = _getUrgencyLevelByCategory(value);
            });
          },
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _getUrgencyColor(_selectedUrgencyLevel).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getUrgencyColor(_selectedUrgencyLevel).withOpacity(0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.priority_high_rounded,
                color: _getUrgencyColor(_selectedUrgencyLevel),
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text(
                "Urgency Level:",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(_selectedUrgencyLevel),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _selectedUrgencyLevel,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassicFileUploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              text: "File Upload ",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: "*",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  onPressed: _chooseEvidenceFile,
                  child: const Text(
                    "Choose File",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Text(
                _getFileDisplayText(),
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _addAnotherFile,
                    activeColor: AppColors.darkGreen,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) {
                      setState(() {
                        _addAnotherFile = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    "Add another?",
                    style: TextStyle(color: AppColors.textDark, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(
                height: 34,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkGreen,
                    side: const BorderSide(color: AppColors.darkGreen),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: _takeEvidencePhoto,
                  icon: const Icon(Icons.camera_alt_outlined, size: 15),
                  label: const Text("Camera", style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          if (_selectedEvidenceFiles.length > 1) ...[
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _selectedEvidenceFiles.map((file) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file_outlined,
                        size: 15,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          file.name,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.darkGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.darkGreen, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownBox({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: const TextStyle(color: AppColors.textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkGreen),
        ),
      ),
      items: options.map((String opt) {
        return DropdownMenuItem<String>(value: opt, child: Text(opt));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextFieldBox({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textLight, size: 18),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildMapActionTemplate(IconData icon, String text) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          side: const BorderSide(color: AppColors.darkGreen, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Launching interactive map selector subsystem overlay...",
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: Icon(icon, size: 16),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}
