import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class ReportIncidentPage extends StatelessWidget {
  const ReportIncidentPage({super.key});

  Widget appLogo() {
    return Container(
      height: 40,
      width: 40,
      padding: const EdgeInsets.all(3),
      color: Colors.white,
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            /// FORM PROGRESS
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

                    children: const [
                      Text(
                        "Form Progress",
                        style: TextStyle(color: Colors.grey),
                      ),

                      Text(
                        "0% Complete",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: 0,
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

                  /// REPORTER INFO
                  sectionTitle(Icons.person_outline, "Reporter Information"),

                  const SizedBox(height: 15),

                  dropdownBox("Complainant Name", "Anonymous"),

                  const SizedBox(height: 30),

                  /// LOCATION
                  sectionTitle(Icons.location_on_outlined, "Location"),

                  const SizedBox(height: 15),

                  dropdownBox("Barangay", "Moonwalk"),

                  const SizedBox(height: 15),

                  textFieldBox(
                    "Location Coordinates (Optional)",
                    Icons.gps_fixed,
                  ),

                  const SizedBox(height: 20),

                  bigButton(Icons.location_pin, "Pin Location on Map"),

                  const SizedBox(height: 30),

                  /// EVIDENCE
                  sectionTitle(
                    Icons.camera_alt_outlined,
                    "Evidence (Optional)",
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: bigButton(Icons.photo, "Upload Photo")),

                      const SizedBox(width: 15),

                      Expanded(
                        child: bigButton(Icons.camera_alt, "Take Photo"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// DESCRIPTION
                  sectionTitle(
                    Icons.description_outlined,
                    "Incident Description",
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    maxLines: 5,

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

                      onPressed: () {},

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

  Widget dropdownBox(String label, String value) {
    return DropdownButtonFormField<String>(
      value: value,

      decoration: InputDecoration(
        labelText: label,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),

      items: [DropdownMenuItem(value: value, child: Text(value))],

      onChanged: (value) {},
    );
  }

  Widget textFieldBox(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget bigButton(IconData icon, String text) {
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

        onPressed: () {},

        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }
}
