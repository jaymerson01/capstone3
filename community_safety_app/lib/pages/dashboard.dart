import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../components/side_menu.dart';
import 'report_incident.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Widget logoBox() {
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

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      case "Low":
        return Colors.green;
      default:
        return AppColors.textLight;
    }
  }

  IconData _getIncidentIcon(String category) {
    switch (category) {
      case "Fire Incident":
        return Icons.local_fire_department;
      case "Theft / Robbery":
        return Icons.local_police;
      case "Medical Emergency":
        return Icons.medical_services;
      case "Road Accident":
        return Icons.car_crash;
      case "Suspicious Activity":
        return Icons.visibility;
      case "Flood / Calamity":
        return Icons.flood;
      case "Noise Complaint":
        return Icons.volume_up;
      default:
        return Icons.report_problem;
    }
  }

  Widget _buildSampleReportCard({
    required String category,
    required String location,
    required String time,
    required String urgency,
    required String description,
    required String status,
  }) {
    final urgencyColor = _getUrgencyColor(urgency);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: urgencyColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIncidentIcon(category),
              color: urgencyColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: urgencyColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$urgency Priority",
                        style: TextStyle(
                          color: urgencyColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 15,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Community Incident Updates",
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Recent reports from nearby compounds and streets",
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        _buildSampleReportCard(
          category: "Fire Incident",
          location: "St. Joseph Compound, Moonwalk",
          time: "Reported 10 minutes ago",
          urgency: "High",
          description:
              "A resident reported smoke coming from a house kitchen area. Nearby residents are advised to stay away from the affected area.",
          status: "Responder Alerted",
        ),

        _buildSampleReportCard(
          category: "Suspicious Activity",
          location: "Sampaguita Street, Moonwalk",
          time: "Reported 25 minutes ago",
          urgency: "Medium",
          description:
              "A suspicious person was seen roaming near parked motorcycles. Residents are advised to secure their gates and vehicles.",
          status: "Under Monitoring",
        ),

        _buildSampleReportCard(
          category: "Road Accident",
          location: "Moonwalk Main Road",
          time: "Reported 40 minutes ago",
          urgency: "High",
          description:
              "Minor road accident involving a motorcycle and private vehicle. Motorists are advised to slow down in the area.",
          status: "In Progress",
        ),

        _buildSampleReportCard(
          category: "Noise Complaint",
          location: "Camella Compound, Moonwalk",
          time: "Reported 1 hour ago",
          urgency: "Low",
          description:
              "Loud music was reported by nearby residents. Barangay personnel may verify if the noise continues.",
          status: "Pending Review",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Row(
          children: [
            logoBox(),
            const SizedBox(width: 10),
            const Text(
              "RESQ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              child: Icon(Icons.person),
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
            // Welcome Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Moonwalk Paranaque",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.accentBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Video Instructions Card
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), AppColors.primary],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Video Instructions",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "How to report safety issues in Moonwalk",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Report Incident CTA Button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBg,
                  foregroundColor: AppColors.primary,
                  elevation: 2,
                  shadowColor: AppColors.primary.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.warning_amber_rounded, size: 24),
                label: const Text(
                  "Report Incident",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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

            const SizedBox(height: 28),

            // Sample Reports Section
            _buildCommunityReportsSection(),
          ],
        ),
      ),
    );
  }
}
