import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  final List<String> _categories = ["Theft", "Accident", "Fire", "Violence", "Suspicious Activity"];
  final List<String> _locations = ["Moonwalk", "Jacinto", "Purok 7", "Doang Batang", "Pepa Compound"];
  final List<String> _severities = ["Low", "Medium", "High"];

  @override
  void dispose() {
    _customNameController.dispose();
    _descriptionController.dispose();
    _coordinatesController.dispose();
    super.dispose();
  }

  Widget appLogo() {
    return Container(
      height: 40,
      width: 40,
      padding: const EdgeInsets.all(3),
      color: Colors.white,
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }

  // Calculate Form Progress percentage based on completed fields
  double _calculateProgress() {
    double progress = 0;
    if (_descriptionController.text.isNotEmpty) progress += 0.3;
    if (_selectedCategory.isNotEmpty) progress += 0.2;
    if (_selectedLocation.isNotEmpty) progress += 0.2;
    if (_selectedSeverity.isNotEmpty) progress += 0.2;
    
    // Custom name filled check
    if (_complainantChoice != "Other" || _customNameController.text.isNotEmpty) {
      progress += 0.1;
    }
    return progress;
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

    final newId = "REP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    final newIncident = IncidentModel(
      id: newId,
      residentId: 'res-999',
      title: "$_selectedCategory in Barangay $_selectedLocation",
      description: _descriptionController.text.trim(),
      latitude: 14.4796,
      longitude: 121.0196,
      humanReadableAddress: "Barangay $_selectedLocation",
      timestamp: DateTime.now(),
      imagePath: 'assets/images/logo.png',
      status: IncidentStatus.pending,
    );

    // Dispatch dynamic bloc event (which writes to the database)
    context.read<IncidentBloc>().add(AddIncident(newIncident));

    // Also manually notify database of custom reporter name since Bloc defaults to "Anonymous Resident"
    context.read<IncidentBloc>().stream.first.then((_) {
      // Find the created raw record and update its reporterName field
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
            Text("Incident $newId reported under '$reporterName'!"),
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

  @override
  Widget build(BuildContext context) {
    double progress = _calculateProgress();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            appLogo(),
            const SizedBox(width: 10),
            const Text(
              "Report Incident",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.help_outline, color: Colors.green),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// FORM PROGRESS CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Form Progress",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "${(progress * 100).toInt()}% Complete",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 25),
                  const Center(
                    child: Text(
                      "Incident Details",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// REPORTER INFO SECTION
                  sectionTitle(Icons.person_outline, "Reporter Information"),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _complainantChoice,
                    decoration: InputDecoration(
                      labelText: "Complainant Identity",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Anonymous", child: Text("Anonymous")),
                      DropdownMenuItem(value: "John David Echano", child: Text("John David Echano (Resident)")),
                      DropdownMenuItem(value: "Other", child: Text("Other (Enter Custom Name...)")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _complainantChoice = value;
                        });
                      }
                    },
                  ),
                  
                  // Conditional Custom Name Field
                  if (_complainantChoice == "Other") ...[
                    const SizedBox(height: 15),
                    TextField(
                      controller: _customNameController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.edit_note),
                        labelText: "Enter Complainant Name",
                        hintText: "Type full name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),

                  /// INCIDENT CATEGORY SECTION
                  sectionTitle(Icons.warning_amber_outlined, "Incident Category"),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Select Category",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 30),

                  /// LOCATION SECTION
                  sectionTitle(Icons.location_on_outlined, "Location & Area"),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: InputDecoration(
                      labelText: "Select Area / Barangay",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    items: _locations.map((loc) => DropdownMenuItem(value: loc, child: Text("Barangay $loc"))).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLocation = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _coordinatesController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.gps_fixed),
                      hintText: "Location Coordinates (Optional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  bigButton(Icons.location_pin, "Pin Location on Map", () {
                    // Pre-fill simulated coordinates
                    setState(() {
                      _coordinatesController.text = "14.4796° N, 121.0196° E";
                    });
                  }),
                  const SizedBox(height: 30),

                  /// SEVERITY LEVEL
                  sectionTitle(Icons.bar_chart_outlined, "Severity Level"),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedSeverity,
                    decoration: InputDecoration(
                      labelText: "Report Severity",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    items: _severities.map((sev) => DropdownMenuItem(value: sev, child: Text(sev))).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSeverity = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 30),

                  /// EVIDENCE SECTION
                  sectionTitle(Icons.camera_alt_outlined, "Evidence (Optional)"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: bigButton(Icons.photo, "Upload Photo", () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Simulated evidence photo uploaded!")),
                          );
                        }),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: bigButton(Icons.camera_alt, "Take Photo", () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Simulated camera photo captured!")),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  /// DESCRIPTION SECTION
                  sectionTitle(Icons.description_outlined, "Incident Description"),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Describe the incident here...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: const Text(
                        "Submit Report",
                        style: TextStyle(fontSize: 18),
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

  Widget sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(width: 15),
        Text(
          title,
          style: const TextStyle(
            color: Colors.green,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget bigButton(IconData icon, String text, VoidCallback onPressed) {
    return SizedBox(
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }
}
