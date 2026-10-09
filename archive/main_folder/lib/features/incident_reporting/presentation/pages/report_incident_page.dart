import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/shared_incident_database.dart';
import '../theme/app_colors.dart';
import '../blocs/incident_bloc.dart';
import '../../data/models/incident_model.dart';

class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  // Form State Controllers
  String _selectedCategory = "Theft";
  String _selectedLocation = "Moonwalk";
  String _selectedSeverity = "Medium";
  String _complainantChoice = "Anonymous";

  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _coordinatesController = TextEditingController();

  final List<String> _categories = [
    "Theft",
    "Accident",
    "Fire",
    "Violence",
    "Suspicious Activity",
  ];
  final List<String> _locations = [
    "Moonwalk",
    "Jacinto",
    "Purok 7",
    "Doang Batang",
    "Pepa Compound",
  ];
  final List<String> _severities = ["Low", "Medium", "High"];

  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedEvidenceFiles = [];
  bool _addAnotherFile = false;

  @override
  void dispose() {
    _customNameController.dispose();
    _descriptionController.dispose();
    _coordinatesController.dispose();
    super.dispose();
  }

  // Calculate Form Progress percentage based on completed fields
  double _calculateProgress() {
    double progress = 0;
    if (_descriptionController.text.isNotEmpty) progress += 0.3;
    if (_selectedCategory.isNotEmpty) progress += 0.2;
    if (_selectedLocation.isNotEmpty) progress += 0.2;
    if (_selectedSeverity.isNotEmpty) progress += 0.2;

    // Custom name filled check
    if (_complainantChoice != "Other" ||
        _customNameController.text.isNotEmpty) {
      progress += 0.1;
    }
    return progress;
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
              Text('Call $agencyName?'),
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

  void _submitForm() {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an incident description first!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String reporterName = "Anonymous";
    if (_complainantChoice == "John David Echano") {
      reporterName = "John David Echano";
    } else if (_complainantChoice == "Other") {
      reporterName = _customNameController.text.trim().isNotEmpty
          ? _customNameController.text.trim()
          : "Anonymous";
    }

    final newId =
        "REP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    final imagePath = _selectedEvidenceFiles.isNotEmpty
        ? _selectedEvidenceFiles.first.path
        : 'assets/images/logo.png';

    final newIncident = IncidentModel(
      id: newId,
      residentId: 'res-999',
      title: "$_selectedCategory in Barangay $_selectedLocation",
      description: _descriptionController.text.trim(),
      latitude: 14.4796,
      longitude: 121.0196,
      humanReadableAddress: "Barangay $_selectedLocation",
      timestamp: DateTime.now(),
      imagePath: imagePath,
      status: IncidentStatus.pending,
    );

    // Dispatch dynamic bloc event (which writes to the database)
    context.read<IncidentBloc>().add(AddIncident(newIncident));

    // Notify database of custom reporter name since Bloc defaults to "Anonymous Resident"
    context.read<IncidentBloc>().stream.first.then((_) {
      final rawList = SharedIncidentDatabase().getRawIncidents();
      final index = rawList.indexWhere((r) => r['id'] == newId);
      if (index != -1) {
        final updated = Map<String, dynamic>.from(rawList[index]);
        updated['reporterName'] = reporterName;
        SharedIncidentDatabase().saveIncident(updated);
      }
    });

    // Show custom success Toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text("Incident $newId reported under '$reporterName'!"),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    // Close screen
    Navigator.pop(context);
  }

  Widget _buildAppLogo() {
    return Container(
      height: 34,
      width: 34,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.security, size: 18, color: AppColors.darkGreen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = _calculateProgress();
    bool step1Active = _complainantChoice.isNotEmpty;
    bool step2Active = _selectedLocation.isNotEmpty;
    bool step3Active = _selectedEvidenceFiles.isNotEmpty;
    bool step4Active = _descriptionController.text.isNotEmpty;

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
            _buildStepperProgressHeader(
              progress,
              step1Active,
              step2Active,
              step3Active,
              step4Active,
            ),
            const SizedBox(height: 24),
            _buildPrimaryFormContainer(progress),
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                  color: AppColors.danger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: AppColors.danger,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Immediate Threat? Emergency Hotlines",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
            color: AppColors.danger.withValues(alpha: 0.5),
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

  Widget _buildStepperProgressHeader(
    double progress,
    bool step1Active,
    bool step2Active,
    bool step3Active,
    bool step4Active,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Report Submission Process",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}% Complete",
                style: const TextStyle(
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
              _buildStepperDot(1, "Info", step1Active),
              _buildStepperLine(step2Active),
              _buildStepperDot(2, "Location", step2Active),
              _buildStepperLine(step3Active),
              _buildStepperDot(3, "Evidence", step3Active),
              _buildStepperLine(step4Active),
              _buildStepperDot(4, "Details", step4Active),
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
                      color: AppColors.darkGreen.withValues(alpha: 0.2),
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

  Widget _buildPrimaryFormContainer(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade100,
            color: AppColors.darkGreen,
          ),
          const SizedBox(height: 24),

          _buildSectionTitle(Icons.person_outline, "Reporter Information"),
          const SizedBox(height: 14),
          _buildDropdownBox(
            label: "Complainant Identity",
            value: _complainantChoice,
            options: ["Anonymous", "John David Echano", "Other"],
            onChanged: (val) => setState(() => _complainantChoice = val!),
          ),

          if (_complainantChoice == "Other") ...[
            const SizedBox(height: 14),
            _buildTextFieldBox(
              hint: "Enter Complainant Name",
              icon: Icons.edit_note,
              controller: _customNameController,
            ),
          ],

          const SizedBox(height: 28),

          _buildSectionTitle(Icons.warning_amber_outlined, "Incident Category"),
          const SizedBox(height: 14),
          _buildDropdownBox(
            label: "Select Category",
            value: _selectedCategory,
            options: _categories,
            onChanged: (val) => setState(() => _selectedCategory = val!),
          ),

          const SizedBox(height: 28),

          _buildSectionTitle(Icons.location_on_outlined, "Location Context"),
          const SizedBox(height: 14),
          _buildDropdownBox(
            label: "Select Area / Barangay",
            value: _selectedLocation,
            options: _locations,
            onChanged: (val) => setState(() => _selectedLocation = val!),
          ),
          const SizedBox(height: 14),
          _buildTextFieldBox(
            hint: "Location Coordinates (Optional)",
            icon: Icons.gps_fixed,
            controller: _coordinatesController,
          ),
          const SizedBox(height: 16),
          _buildMapActionTemplate(Icons.location_pin, "Pin Location on Map"),

          const SizedBox(height: 28),

          _buildSectionTitle(Icons.bar_chart_outlined, "Severity Level"),
          const SizedBox(height: 14),
          _buildDropdownBox(
            label: "Report Severity",
            value: _selectedSeverity,
            options: _severities,
            onChanged: (val) => setState(() => _selectedSeverity = val!),
          ),

          const SizedBox(height: 28),

          _buildSectionTitle(Icons.camera_alt_outlined, "Evidence Attachment"),
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
            maxLines: 5,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText:
                  "Describe the incident timeline, visible hazards, or actors involved in detail...",
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
                shadowColor: AppColors.darkGreen.withValues(alpha: 0.4),
              ),
              onPressed: _submitForm,
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
              text: "Evidence Photos ",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: "(Optional)",
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.normal,
                  ),
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

          if (_selectedEvidenceFiles.isNotEmpty) ...[
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
            color: AppColors.darkGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.darkGreen, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.bold,
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
      initialValue: value,
      dropdownColor: Colors.white,
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
      onChanged: (_) => setState(() {}),
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
          // Simulated coordinates pre-fill
          setState(() {
            _coordinatesController.text = "14.4796° N, 121.0196° E";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Simulated location coordinates pinned to form!"),
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
