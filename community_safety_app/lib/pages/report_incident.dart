import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  // Stepper current active step simulation
  int currentStep = 2; // e.g. Location step is active

  Widget appLogo() {
    return Container(
      height: 36,
      width: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
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
        title: Row(
          children: [
            appLogo(),
            const SizedBox(width: 10),
            const Text(
              "Report Incident",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              child: Icon(Icons.help_outline),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STEPPER PROGRESS HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
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
                        style: TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.w600),
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
                  const SizedBox(height: 16),
                  
                  // Custom Visual Stepper Dots
                  Row(
                    children: [
                      _stepperDot(1, "Info", true),
                      _stepperLine(true),
                      _stepperDot(2, "Location", true),
                      _stepperLine(false),
                      _stepperDot(3, "Evidence", false),
                      _stepperLine(false),
                      _stepperDot(4, "Details", false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FORM CONTAINER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
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
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  /// REPORTER INFO
                  sectionTitle(Icons.person_outline, "Reporter Information"),
                  const SizedBox(height: 16),
                  dropdownBox("Complainant Name", "Anonymous"),

                  const SizedBox(height: 32),

                  /// LOCATION
                  sectionTitle(Icons.location_on_outlined, "Location"),
                  const SizedBox(height: 16),
                  dropdownBox("Barangay", "Moonwalk"),
                  const SizedBox(height: 16),
                  textFieldBox(
                    "Location Coordinates (Optional)",
                    Icons.gps_fixed,
                  ),
                  const SizedBox(height: 20),
                  bigButton(Icons.map_outlined, "Pin Location on Map", false),

                  const SizedBox(height: 32),

                  /// EVIDENCE
                  sectionTitle(
                    Icons.camera_alt_outlined,
                    "Evidence (Optional)",
                  ),
                  const SizedBox(height: 20),

                  // File upload visual drop boxes
                  Row(
                    children: [
                      Expanded(child: uploadBox(Icons.photo_library_outlined, "Upload Photo")),
                      const SizedBox(width: 16),
                      Expanded(child: uploadBox(Icons.camera_alt_outlined, "Take Photo")),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// DESCRIPTION
                  sectionTitle(
                    Icons.description_outlined,
                    "Incident Description",
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Please describe the incident in detail...",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit CTA button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                        shadowColor: AppColors.darkGreen.withOpacity(0.3),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Submitting safety incident report..."),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        "Submit Report",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperDot(int step, String label, bool isCompletedOrActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompletedOrActive ? AppColors.darkGreen : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompletedOrActive ? AppColors.darkGreen : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompletedOrActive
                ? const Icon(Icons.check, size: 16, color: Colors.white)
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
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isCompletedOrActive ? AppColors.textDark : AppColors.textLight,
            fontSize: 10,
            fontWeight: isCompletedOrActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _stepperLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.darkGreen : Colors.grey.shade200,
        margin: const EdgeInsets.only(bottom: 16),
      ),
    );
  }

  Widget sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accentGreenBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.darkGreen, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget dropdownBox(String label, String value) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textLight),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: [DropdownMenuItem(value: value, child: Text(value))],
      onChanged: (value) {},
    );
  }

  Widget textFieldBox(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textLight, size: 18),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget uploadBox(IconData icon, String text) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.darkGreen, size: 28),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bigButton(IconData icon, String text, bool isPrimary) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          side: const BorderSide(color: AppColors.darkGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
        icon: Icon(icon, size: 18),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

