import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/side_menu.dart';
import 'report_incident_page.dart';

class ResidentDashboardPage extends StatelessWidget {
  const ResidentDashboardPage({super.key});

  Widget logoBox() {
    return Container(
      height: 40,
      width: 40,
      padding: const EdgeInsets.all(3),
      color: Colors.white,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            logoBox(),
            const SizedBox(width: 10),
            const Text(
              "Safe Moonwalk",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Moonwalk Paranaque!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline, color: Colors.white, size: 70),
                  SizedBox(height: 10),
                  Text(
                    "Video Instructions",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6F0D6),
                  foregroundColor: AppColors.darkGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.warning_amber),
                label: const Text(
                  "Report Incident",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportIncidentPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Incomplete Reports",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Text("🔥", style: TextStyle(fontSize: 40)),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fire Incident",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 15),
                          Text(" 16-03-2026   "),
                          Icon(Icons.location_on, size: 15, color: Colors.grey),
                          Text(" St. Francis Compound"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Unsubmitted Reports",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 85,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
