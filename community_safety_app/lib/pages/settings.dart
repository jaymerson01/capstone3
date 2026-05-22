import 'package:flutter/material.dart';

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
      colors: [Color(0xFF004D00), Color(0xFF9EA89E)],
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
        leading: const Icon(
          Icons.menu,
          color: Colors.black,
          size: 28,
        ), // Matches design image menu icon
        title: const Text(
          "SETTINGS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(
          top: 100,
          left: 25,
          right: 25,
          bottom: 25,
        ),
        decoration: kAppBackgroundGradient,
        child: Column(
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
                activeColor: const Color(0xFF004D00),
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
                activeColor: const Color(0xFF004D00),
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
              subtitle: "Change password, two-factor authentication",
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
              subtitle: "App version, developer info, terms and policies",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppPage()),
              ),
            ),

            const Spacer(),

            // BACK NAVIGATION BUTTON
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "> BACK",
                    style: TextStyle(fontWeight: FontWeight.bold),
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
      margin: const EdgeInsets.only(bottom: 25),
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, size: 36, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.3),
        ),
        trailing: trailing,
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

  // Function to show the Native Date Picker Calendar Popup
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 1, 1),
      firstDate: DateTime(1920), // Minimum year limit
      lastDate: DateTime(
        2050,
      ), // FIXED: Expanded calendar allowance far past 2026 up to 2050!
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF004D00), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body calendar elements text color
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
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF004D00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 65, color: Colors.grey[600]),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF004D00),
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
            ),

            // CALENDAR FIELD
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                controller: _birthdayController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: 'Birthdate',
                  hintText: 'Select your birthdate',
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: Color(0xFF004D00),
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF004D00), width: 2),
                  ),
                ),
              ),
            ),

            _buildTextField(
              label: 'Contact Info',
              initialValue: 'johnechano@gmail.com',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D00),
                  foregroundColor: Colors.white,
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF004D00), width: 2),
          ),
        ),
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
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: const Color(0xFF004D00),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Authentication Update',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            subtitle: const Text('Modify your private account credential key'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showChangePasswordDialog(context),
          ),
          const SizedBox(height: 24),
          const Text(
            'Two-Factor Authentication (2FA)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.phonelink_lock_outlined),
            title: const Text('Secure 2FA Authentication'),
            subtitle: const Text(
              'Require secondary text confirmation layout to lock entry',
            ),
            value: is2FAEnabled,
            activeColor: const Color(0xFF004D00),
            onChanged: (bool value) {
              setState(() {
                is2FAEnabled = value;
              });
              if (value) {
                _showTwoFactorSetupDialog(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
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
              backgroundColor: const Color(0xFF004D00),
              foregroundColor: Colors.white,
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
        title: Row(
          children: const [
            Icon(Icons.security, color: Color(0xFF004D00)),
            SizedBox(width: 10),
            Text('Enable 2FA Verification'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your verification channels setup to receive secondary platform credentials access.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 10),
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
              backgroundColor: const Color(0xFF004D00),
              foregroundColor: Colors.white,
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
      appBar: AppBar(
        title: const Text('About & Policies'),
        backgroundColor: const Color(0xFF004D00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.health_and_safety,
                size: 70,
                color: Color(0xFF004D00),
              ),
            ),
            const Center(
              child: Text(
                'Safe Moonwalk v1.0.0',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Community Guard Reminders',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF004D00),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '1. Always ensure active geolocation monitoring tracking configurations are enabled when moving through unsafe or dimly lit perimeters.\n\n'
                '2. Incident notifications are pushed instantly to local barangay administration dispatch assets for rapid intervention processing layout configurations.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Terms of Service & Privacy Protocol',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF004D00),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Your location data is collected purely based on real-time incident geo-reporting mechanisms. '
                'All credential strings, communication assets data, and profile settings configurations map details are encrypted '
                'accordingly following governance compliance protocols in alignment with local municipal privacy guidelines.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
