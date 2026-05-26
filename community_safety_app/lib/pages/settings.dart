import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_color.dart';
import 'welcome_page.dart';

// Note: Ensure you run `flutter pub add url_launcher` in your terminal
// and import 'package:url_launcher/url_launcher.dart'; to execute direct phone dialers.

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Global State Variables for Toggles
  bool isLocationEnabled = true;
  bool isNotificationEnabled = true;
  bool isDarkMode = false;
  bool isBiometricsEnabled = true;

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
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
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
        decoration: kAppBackgroundGradient,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  children: [
                    /// 1. PROFILE HEADER SECTION CARD
                    _buildProfileHeaderCard(),
                    const SizedBox(height: 24),

                    /// 2. COMMUNITY SAFETY & EMERGENCY INSTANT DIALER
                    _buildSectionTitle("Barangay Emergency Hotlines"),
                    const SizedBox(height: 12),
                    _buildEmergencyHotlineGrid(),
                    const SizedBox(height: 24),

                    /// 3. ACCOUNT PROFILE CONFIGURATIONS
                    _buildSectionTitle("Account Settings"),
                    const SizedBox(height: 12),
                    _buildSettingTile(
                      icon: Icons.account_circle_outlined,
                      title: "Edit Personal Details",
                      subtitle: "Name, email, contact channels, addresses",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.shield_outlined,
                      title: "Privacy & Account Security",
                      subtitle:
                          "Change password, active Biometric ID Gateway Login",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacySecurityPage(),
                        ),
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.history_toggle_off_rounded,
                      title: "Incident Report History",
                      subtitle: "Track your filed community protection logs",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Navigating to comprehensive Report Logs...",
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Preferences"),
                    const SizedBox(height: 12),

                    /// 4. INTEGRATED TOGGLE MATRICES
                    _buildSettingTile(
                      icon: Icons.location_on_outlined,
                      title: "Location Monitoring",
                      subtitle: "Real-time incident geo-tracking metrics",
                      trailing: Switch(
                        value: isLocationEnabled,
                        activeColor: AppColors.darkGreen,
                        onChanged: (value) =>
                            setState(() => isLocationEnabled = value),
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.notifications_none_outlined,
                      title: "Push Notifications",
                      subtitle:
                          "Instant local danger perimeter broadcast alerts",
                      trailing: Switch(
                        value: isNotificationEnabled,
                        activeColor: AppColors.darkGreen,
                        onChanged: (value) =>
                            setState(() => isNotificationEnabled = value),
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.dark_mode_outlined,
                      title: "Night Mode Dynamic Range",
                      subtitle: "High contrast dark-mode viewing layer",
                      trailing: Switch(
                        value: isDarkMode,
                        activeColor: AppColors.darkGreen,
                        onChanged: (value) =>
                            setState(() => isDarkMode = value),
                      ),
                    ),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Support & Overview"),
                    const SizedBox(height: 12),

                    /// 5. APP UTILITIES SECTION
                    _buildSettingTile(
                      icon: Icons.info_outline,
                      title: "About Application",
                      subtitle:
                          "App versions, platform structural mandates, guidelines",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutAppPage(),
                        ),
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.help_outline_rounded,
                      title: "Help Desk & Customer Support",
                      subtitle: "Get live system guidance or read user guides",
                      onTap: () => _showModalInformation(
                        context,
                        "Help & Support",
                        "For application assistance, email support@resq.gov.ph or contact the municipal tech division desk directly.",
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.bug_report_outlined,
                      title: "Submit App Feedback & Bugs",
                      subtitle:
                          "Report framework formatting flaws or request features",
                      onTap: () => _showFeedbackDialog(context),
                    ),

                    const SizedBox(height: 28),

                    /// 6. CRITICAL ACCOUNT ACCOUNTABILITY BUTTONS
                    _buildDestructiveActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // PERSISTENT FOOTER UTILITY
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 20,
                  top: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "ResQ Enterprise",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "v1.0.4 Premium Edition",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'avatar_profile',
            child: CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.accentGreenBg,
              child: const Icon(
                Icons.person,
                size: 40,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "John David Echano",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "johnechano@gmail.com",
                  style: TextStyle(fontSize: 13, color: AppColors.textLight),
                ),
                SizedBox(height: 2),
                Text(
                  "Verified Resident • Parañaque City",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyHotlineGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildHotlineButton(
              "Police Department",
              Icons.local_police_outlined,
              "911",
              itemWidth,
            ),
            _buildHotlineButton(
              "Fire Command Station",
              Icons.local_fire_department_outlined,
              "112",
              itemWidth,
            ),
            _buildHotlineButton(
              "Ambulance Medical Team",
              Icons.medical_services_outlined,
              "143",
              itemWidth,
            ),
            _buildHotlineButton(
              "Barangay Desk Center",
              Icons.phone_in_talk_outlined,
              "888-9999",
              itemWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildHotlineButton(
    String agency,
    IconData icon,
    String dialNum,
    double targetWidth,
  ) {
    return SizedBox(
      width: targetWidth,
      height: 46,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE2E2),
          foregroundColor: Colors.red.shade800,
          elevation: 0,
          side: BorderSide(color: Colors.red.shade200, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: () => _triggerEmergencyCall(agency, dialNum),
        icon: Icon(icon, size: 16, color: Colors.red.shade700),
        label: Text(
          agency.split(' ')[0],
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  void _triggerEmergencyCall(String target, String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text("Emergency System Outbound"),
          ],
        ),
        content: Text(
          "Are you completely sure you want to dial the dispatch line for $target ($number)?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ABORT"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Implementation using url_launcher logic wrapper string format:
              // launchUrl(Uri.parse('tel:$number'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Initiating secure dial routing to: $number...",
                  ),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            child: const Text("DIAL CALL"),
          ),
        ],
      ),
    );
  }

  Widget _buildDestructiveActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white60, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _triggerAccountActionDialog(
              "Logout",
              "Are you sure you want to exit your profile dashboard session safely?",
              false,
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text(
              "SECURE DASHBOARD LOGOUT",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: Colors.red.shade100),
          onPressed: () => _triggerAccountActionDialog(
            "Delete Profile Account",
            "CRITICAL WARNING: Purging your file credentials wipes all location histories, filed safety status streams, and account backups completely from governance directories. This process is fully irreversible.",
            true,
          ),
          icon: const Icon(Icons.delete_forever, size: 16),
          label: const Text(
            "Permanently Delete Citizen Account Profile",
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _triggerAccountActionDialog(
    String contextTitle,
    String briefMsg,
    bool isSevereDestructive,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          contextTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSevereDestructive
                ? Colors.red.shade900
                : AppColors.textDark,
          ),
        ),
        content: Text(
          briefMsg,
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSevereDestructive
                  ? Colors.red
                  : AppColors.darkGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              if (contextTitle == "Logout") {
                // Clear user persistent session state from Hive
                Hive.box('auth').put('isLoggedIn', false);

                // Navigate back to welcome page clearing screen stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                  (route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Action '$contextTitle' processed successfully.",
                    ),
                  ),
                );
              }
            },
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );
  }

  void _showModalInformation(BuildContext ctx, String head, String paragraph) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              head,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              paragraph,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("CLOSE WINDOW"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Submit App Review / Bug",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Your technical system logs will be paired automatically to accelerate troubleshooting queues.",
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
            SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    "Describe your system performance issue or operational feature request...",
                border: OutlineInputBorder(),
                hintStyle: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("DISMISS"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Feedback logs queued for developer team dispatch!",
                  ),
                ),
              );
            },
            child: const Text("SUBMIT TICKET"),
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreenBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: AppColors.darkGreen),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                if (onTap != null && trailing == null)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textLight,
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= SUB PAGE: DETAIL RESIDENT PROFILE CORES =================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _profileFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController(
    text: "John David Echano",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "johnechano@gmail.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "+63 917 123 4567",
  );
  final TextEditingController _emergencyContactController =
      TextEditingController(text: "Maria Echano (0919-888-7766)");
  final TextEditingController _savedAddressController = TextEditingController(
    text: "Bldg 4, St. Francis Compound, Moonwalk",
  );

  String _selectedBarangay = 'Moonwalk';
  String _selectedLanguage = 'English (PH)';

  final List<String> _barangayList = [
    'Moonwalk',
    'Don Bosco',
    'Sun Valley',
    'San Martin De Porres',
    'Sto. Niño',
  ];
  final List<String> _languages = [
    'English (PH)',
    'Filipino (Tagalog)',
    'Spanish',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _savedAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Identity Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _profileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// AVATAR INTERFACE BLOCK
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.accentGreenBg,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.darkGreen,
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Triggering system filesystem photo upload asset index selector...",
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionSubHeader("Primary Credentials"),
              const SizedBox(height: 12),
              _buildValidatedField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person_outline_rounded,
                validator: (val) => val!.trim().isEmpty
                    ? "Account registration requires a valid name asset reference"
                    : null,
              ),
              const SizedBox(height: 16),
              _buildValidatedField(
                controller: _emailController,
                label: "Email Coordinate",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => !val!.contains('@')
                    ? "Provide an authentic account email identifier string"
                    : null,
              ),
              const SizedBox(height: 16),
              _buildValidatedField(
                controller: _phoneController,
                label: "Mobile Number",
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                validator: (val) => val!.trim().length < 7
                    ? "Active phone context sequence string required"
                    : null,
              ),

              const SizedBox(height: 24),
              _buildSectionSubHeader("Community Security Links"),
              const SizedBox(height: 12),
              _buildValidatedField(
                controller: _emergencyContactController,
                label: "Primary Emergency Contact",
                icon: Icons.contact_emergency_outlined,
                validator: (val) => val!.trim().isEmpty
                    ? "Emergency fallback nodes must not be blank strings"
                    : null,
              ),
              const SizedBox(height: 16),
              _buildValidatedField(
                controller: _savedAddressController,
                label: "Resident Location/Home Address",
                icon: Icons.maps_home_work_outlined,
                validator: (val) => val!.trim().isEmpty
                    ? "Physical tracking coordinates must be mapped"
                    : null,
              ),
              const SizedBox(height: 16),

              /// BARANGAY ANCHOR DROPDOWN
              DropdownButtonFormField<String>(
                value: _selectedBarangay,
                decoration: InputDecoration(
                  labelText: "Preferred Sector/Barangay jurisdiction",
                  prefixIcon: const Icon(
                    Icons.holiday_village_outlined,
                    color: AppColors.textLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _barangayList
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedBarangay = val!),
              ),
              const SizedBox(height: 16),

              /// REGIONAL LANGUAGE DROPDOWN
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: InputDecoration(
                  labelText: "App Language Interface Locale",
                  prefixIcon: const Icon(
                    Icons.translate_rounded,
                    color: AppColors.textLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _languages
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedLanguage = val!),
              ),

              const SizedBox(height: 36),

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
                    if (_profileFormKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Profile modifications updated successfully into internal system storage.',
                          ),
                          backgroundColor: AppColors.darkGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'SAVE PROFILE CHANGES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionSubHeader(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildValidatedField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textLight),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        errorStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ================= SUB PAGE: PRIVACY & SYSTEM SECURITY MATRIX =================
class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  final _passFormKey = GlobalKey<FormState>();
  final TextEditingController _currentPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool isBiometricActive = true;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Privacy & Security Suite',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Security Credentials Framework',
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
                decoration: const BoxDecoration(
                  color: AppColors.accentGreenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.darkGreen,
                  size: 20,
                ),
              ),
              title: const Text(
                'Update Secret Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Perform routine rotation changes for credentials protection',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _displayChangePasswordSheet(context),
            ),
          ),

          const SizedBox(height: 28),
          const Text(
            'Advanced Device Shielding',
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
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreenBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      color: AppColors.darkGreen,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Biometric ID Gateway Lock',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Authorize fingerprint or face scans before dashboard opens',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: isBiometricActive,
                  activeColor: AppColors.darkGreen,
                  onChanged: (bool value) =>
                      setState(() => isBiometricActive = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _displayChangePasswordSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _passFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reset Account Password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _currentPassCtrl,
                  obscureText: _obscureCurrent,
                  validator: (val) => val!.isEmpty
                      ? "Input verification of your operational password sequence"
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Current Password String',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setModalState(
                        () => _obscureCurrent = !_obscureCurrent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _newPassCtrl,
                  obscureText: _obscureNew,
                  validator: (val) => val!.length < 6
                      ? "New password string dimensions must cross 6 symbols minimum"
                      : null,
                  decoration: InputDecoration(
                    labelText: 'New Structural Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setModalState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPassCtrl,
                  obscureText: _obscureConfirm,
                  validator: (val) => val != _newPassCtrl.text
                      ? "Mismatch detected across structural verification input matrices"
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Structural Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setModalState(
                        () => _obscureConfirm = !_obscureConfirm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (_passFormKey.currentState!.validate()) {
                        _currentPassCtrl.clear();
                        _newPassCtrl.clear();
                        _confirmPassCtrl.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Account login security configurations updated successfully!",
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("PROCEED UPDATE EXECUTION"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= SUB PAGE: GENERAL APPLICATION POLICIES ARCHIVE =================
class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Platform Legal Framework',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Center(
              child: Icon(
                Icons.health_and_safety_rounded,
                size: 76,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'ResQ Environment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Version 1.0.4 Premium Architecture Build',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 32),

            _buildLegalGlossaryCard(
              "Barangay Moonwalk Emergency Hotlines",
              "• Barangay Hall / Desk: 888-9999\n"
                  "• Local Police Station: 911\n"
                  "• Fire Department: 112\n"
                  "• Medical Response: 143\n\n"
                  "Keep these numbers saved for direct dialing in case of emergency application connectivity issues.",
            ),
            const SizedBox(height: 16),

            _buildLegalGlossaryCard(
              "Terms of Service: Anti-Fake Reporting",
              "By using ResQ, you agree to submit only genuine, factual emergency incident reports.\n\n"
                  "WARNING: Fake reporting and malicious false alarms are statutory offenses punishable by law. "
                  "While the 1987 Constitution of the Philippines guarantees fundamental rights like freedom of speech, it does not protect malicious falsehoods or public disturbances. "
                  "Under Article 154 of the Revised Penal Code (Unlawful use of means of publication and unlawful utterances) and relevant Presidential Decrees (e.g., P.D. 1727) regarding false alarms, perpetrators of fake emergency reports will be subject to account termination, heavy fines, and legal prosecution.",
            ),
            const SizedBox(height: 16),

            _buildLegalGlossaryCard(
              "Privacy Policy: GPS Geolocation Data",
              "Your privacy is a fundamental priority. The ResQ platform strictly collects and transmits your real-time GPS geolocation data ONLY when you actively submit an incident report or trigger an SOS function. "
                  "This spatial data is routed directly to local dispatch consoles to expedite perimeter checks and direct emergency response teams to your exact coordinates. "
                  "Your background location history is securely encrypted, never sold to third parties, and is managed strictly under municipal privacy compliance and the Data Privacy Act of 2012.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalGlossaryCard(String heading, String detailedBody) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detailedBody,
            textAlign: TextAlign
                .justify, // ADDED THIS LINE to justify the text alignment
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
