import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_color.dart';

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
  String _selectedBarangay = "Moonwalk";

  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedEvidenceFiles = [];
  bool _addAnotherFile = false;

  @override
  void dispose() {
    _coordinatesController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
    return Container(
      height: 34,
      width: 34,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
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
            fontWeight:
                isCompletedOrActive ? FontWeight.bold : FontWeight.normal,
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

          _buildSectionTitle(Icons.person_outline, "Reporter Information"),
          const SizedBox(height: 14),
          _buildDropdownBox(
            label: "Complainant Name",
            value: _selectedComplainant,
            options: [
              "Anonymous",
              "Verified Account Profile",
              "Confidential Third-Party",
            ],
            onChanged: (val) => setState(() => _selectedComplainant = val!),
          ),

          const SizedBox(height: 28),

          _buildSectionTitle(Icons.location_on_outlined, "Location Context"),
          const SizedBox(height: 14),
          _buildDropdownBox(
            label: "Barangay",
            value: _selectedBarangay,
            options: ["Moonwalk", "Don Bosco", "Sun Valley", "Merville"],
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

          _buildSectionTitle(
            Icons.attach_file_outlined,
            "Evidence Attachment",
          ),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          "Submitting safety incident report...",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.darkGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
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
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                    ),
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
                  label: const Text(
                    "Camera",
                    style: TextStyle(fontSize: 12),
                  ),
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