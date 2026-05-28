import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class EmergencyHotlinesPage extends StatelessWidget {
  const EmergencyHotlinesPage({super.key});

  void _showCallConfirmation(BuildContext context, String title, String number) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: 28,
              ),
              SizedBox(width: 12),
              Text('Call Dispatch Line?'),
            ],
          ),
          content: Text(
            'Are you sure you want to dial the official hotline for $title ($number) now?',
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                
                // Simulation response
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Connecting call to $title ($number)...',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
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

  Widget _buildHotlineCard(
    BuildContext context, {
    required String title,
    required String number,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.danger,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textLight,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 14,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              number,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _showCallConfirmation(context, title, number),
                        icon: const Icon(Icons.call, size: 14),
                        label: const Text(
                          'CALL NOW',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7BBDE8), Color(0xFF001D39)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Back Nav Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Emergency Hotlines',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Page Title Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'EMERGENCY CALL PORTAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Unauthenticated guest access enabled. Dial emergency responders directly below in case of any immediate active threats.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Scrollable Hotlines List
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildHotlineCard(
                        context,
                        title: 'Police Department Dispatch',
                        number: '911',
                        description: 'Immediate criminal activity reporting, neighborhood patrols, threat neutralization, and public order enforcement.',
                        icon: Icons.local_police_outlined,
                      ),
                      _buildHotlineCard(
                        context,
                        title: 'Fire Command Station',
                        number: '112',
                        description: 'Structural active fire emergencies, hazardous chemical leak containment, and immediate search and rescue ops.',
                        icon: Icons.local_fire_department_outlined,
                      ),
                      _buildHotlineCard(
                        context,
                        title: 'Ambulance Medical Team',
                        number: '143',
                        description: 'Severe medical trauma support, critical emergency patient transport, and emergency responder dispatch.',
                        icon: Icons.medical_services_outlined,
                      ),
                      _buildHotlineCard(
                        context,
                        title: 'Barangay Desk Center',
                        number: '888-9999',
                        description: 'Barangay Moonwalk local safety reports, minor community disputes, security desk coordination, and assistance.',
                        icon: Icons.phone_in_talk_outlined,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
