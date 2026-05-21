import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class ReportIncidentPage extends StatelessWidget {
  const ReportIncidentPage({super.key});

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

  Widget reportBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(5),
      height: 35,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.black54),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            logoBox(),
            const SizedBox(width: 10),
            const Text(
              "Safe Moonwalk Report Incidents",
              style: TextStyle(color: Colors.white, fontSize: 15),
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
            const Text("Report New Incident", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.grey.shade300,
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Incident Type"),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Location"),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {},
                    child: const Text("Submit Report"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              color: Colors.grey.shade300,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Recent Report"),
                      const Spacer(),
                      Container(
                        color: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        child: const Text(
                          "View All >",
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black),
                  reportBox("House Fire on St. Francis Compound\n5 mins ago"),
                  reportBox(""),
                  reportBox(""),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}