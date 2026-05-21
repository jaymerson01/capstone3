import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("SETTINGS",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF004D00), Color(0xFF9EA89E)],
          ),
        ),
        child: Column(
          children: [
            settingBox(Icons.person, "Profile", "Edit name, photo, contact info"),
            settingBox(Icons.location_on, "Location Settings",
                "Enable location, services"),
            settingBox(Icons.notifications, "Notification",
                "Incident alerts, emergency warnings"),
            settingBox(Icons.security, "Privacy & Security",
                "Change password, two-factor authentication"),
            settingBox(Icons.info, "About App",
                "App version, developer info, terms and policies"),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context),
                child: const Text("> BACK"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget settingBox(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Icon(icon, size: 35, color: Colors.black),
          const SizedBox(width: 15),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title),
              Text(subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}