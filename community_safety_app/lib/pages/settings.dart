import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State variables for the switch toggles
  bool isLocationEnabled = true;
  bool isNotificationEnabled = true;

  // Background Gradient matching your design image perfectly
  final BoxDecoration kAppBackgroundGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.darkGreen, Color(0xFF9EA89E)],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "SETTINGS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(
          top: 110,
          left: 24,
          right: 24,
          bottom: 24,
        ),
        decoration: kAppBackgroundGradient,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  // PROFILE TILE (Navigates to Edit Page)
                  _buildSettingTile(
                    icon: Icons.account_circle_outlined,
                    title: "Profile",
                    subtitle: "Edit name, photo, contact info",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    ),
                  ),

                  // LOCATION SETTINGS TILE (Contains an embedded Switch toggle)
                  _buildSettingTile(
                    icon: Icons.location_on_outlined,
                    title: "Location Settings",
                    subtitle: "Enable location, services",
                    trailing: Switch(
                      value: isLocationEnabled,
                      activeColor: AppColors.darkGreen,
                      onChanged: (value) {
                        setState(() {
                          isLocationEnabled = value;
                        });
                      },
                    ),
                  ),

                  // NOTIFICATION TILE (Contains an embedded Switch toggle)
                  _buildSettingTile(
                    icon: Icons.notifications_none_outlined,
                    title: "Notification",
                    subtitle: "Incident alerts, emergency warnings",
                    trailing: Switch(
                      value: isNotificationEnabled,
                      activeColor: AppColors.darkGreen,
                      onChanged: (value) {
                        setState(() {
                          isNotificationEnabled = value;
                        });
                      },
                    ),
                  ),

                  // PRIVACY & SECURITY TILE (Navigates to Security Sub-Page)
                  _buildSettingTile(
                    icon: Icons.shield_outlined,
                    title: "Privacy & Security",
                    subtitle: "Change password, 2FA settings",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacySecurityPage(),
                      ),
                    ),
                  ),

                  // ABOUT APP TILE (Navigates to Policies & Reminders Page)
                  _buildSettingTile(
                    icon: Icons.info_outline,
                    title: "About App",
                    subtitle: "App version, policies, and reminders",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutAppPage()),
                    ),
                  ),
                ],
              ),
            ),

            // BACK NAVIGATION BUTTON
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "BACK",
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreenBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: AppColors.darkGreen),
                ),
                const SizedBox(width: 16),
                
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                if (onTap != null && trailing == null)
                  const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= SUB PAGE: EDIT PROFILE =================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _birthdayController = TextEditingController();

  @override
  void dispose() {
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _birthdayController.text =
            "${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.accentGreenBg,
                  child: const Icon(Icons.person, size: 65, color: AppColors.darkGreen),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.darkGreen,
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildTextField(
              label: 'Full Name',
              initialValue: 'John David Echano',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // CALENDAR FIELD
            TextFormField(
              controller: _birthdayController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                labelText: 'Birthdate',
                hintText: 'Select your birthdate',
                prefixIcon: const Icon(Icons.cake_outlined, color: AppColors.textLight),
                suffixIcon: const Icon(
                  Icons.calendar_today,
                  color: AppColors.darkGreen,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              label: 'Contact Info',
              initialValue: 'johnechano@gmail.com',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 40),
            
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
                  elevation: 2,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Changes saved successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'SAVE CHANGES',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, String? initialValue, required IconData icon}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textLight),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ================= SUB PAGE: PRIVACY & SECURITY =================
class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool is2FAEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Authentication Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.accentGreenBg, shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline, color: AppColors.darkGreen, size: 20),
              ),
              title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Modify your private account password', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ),
          
          const SizedBox(height: 32),
          const Text(
            'Two-Factor Authentication (2FA)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.accentGreenBg, shape: BoxShape.circle),
                child: const Icon(Icons.phonelink_lock_outlined, color: AppColors.darkGreen, size: 20),
              ),
              title: const Text('Secure 2FA Authentication', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Require confirmation codes on login attempt', style: TextStyle(fontSize: 12)),
              value: is2FAEnabled,
              activeColor: AppColors.darkGreen,
              onChanged: (bool value) {
                setState(() {
                  is2FAEnabled = value;
                });
                if (value) {
                  _showTwoFactorSetupDialog(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.security, color: AppColors.darkGreen),
            SizedBox(width: 10),
            Text('Enable 2FA', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your verification channels to receive secure platform credentials access.',
              style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => is2FAEnabled = false);
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('ACTIVATE'),
          ),
        ],
      ),
    );
  }
}

// ================= SUB PAGE: ABOUT APP =================
class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About & Policies', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Icon(
                Icons.health_and_safety,
                size: 80,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Safe Moonwalk v1.0.0',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 32),
            
            // Reminders Box
            _buildAboutCard(
              title: 'Community Guard Reminders',
              content: '1. Always ensure active geolocation monitoring tracking configurations are enabled when moving through unsafe or dimly lit perimeters.\n\n'
                  '2. Incident notifications are pushed instantly to local barangay administration dispatch assets for rapid intervention processing.',
            ),
            const SizedBox(height: 20),
            
            // Policies Box
            _buildAboutCard(
              title: 'Terms of Service & Privacy Protocol',
              content: 'Your location data is collected purely based on real-time incident geo-reporting mechanisms. '
                  'All credential strings, communication assets data, and profile settings configurations details are encrypted '
                  'following governance compliance protocols in alignment with local municipal privacy guidelines.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

