import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import 'welcome_page.dart';
import 'my_reports.dart';
import '../services/mock_database_service.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_translations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final BoxDecoration kAppBackgroundGradient = const BoxDecoration(
    gradient: AppColors.sunsetGradient,
  );

  @override
  Widget build(BuildContext context) {
    final user = MockDatabaseService().currentUser;
    final isNotificationEnabled = user?.notificationsEnabled ?? true;
    final isDarkMode = AppStateProvider().isDarkMode;

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
        title: Text(
          AppTranslations.tr('settings'),
          style: const TextStyle(
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
                    _buildSectionTitle(AppTranslations.tr('emergency_hotlines')),
                    const SizedBox(height: 12),
                    _buildEmergencyHotlineGrid(),
                    const SizedBox(height: 24),

                    /// 3. ACCOUNT PROFILE CONFIGURATIONS
                    _buildSectionTitle(AppTranslations.tr('account_settings')),
                    const SizedBox(height: 12),
                    _buildSettingTile(
                      icon: Icons.account_circle_outlined,
                      title: AppTranslations.tr('edit_personal_details'),
                      subtitle: AppTranslations.tr('edit_personal_sub'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.shield_outlined,
                      title: AppTranslations.tr('privacy_security'),
                      subtitle: AppTranslations.tr('privacy_security_sub'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacySecurityPage(),
                        ),
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.history_toggle_off_rounded,
                      title: AppTranslations.tr('report_history'),
                      subtitle: AppTranslations.tr('report_history_sub'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyReportsPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                    _buildSectionTitle(AppTranslations.tr('preferences')),
                    const SizedBox(height: 12),

                    _buildSettingTile(
                      icon: Icons.notifications_none_outlined,
                      title: AppTranslations.tr('push_notifications'),
                      subtitle: AppTranslations.tr('push_notifications_sub'),
                      trailing: Switch(
                        value: isNotificationEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: (value) async {
                          await MockDatabaseService().updateUserSettings(
                            notificationsEnabled: value,
                          );
                          setState(() {});
                        },
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.dark_mode_outlined,
                      title: AppTranslations.tr('night_mode'),
                      subtitle: AppTranslations.tr('night_mode_sub'),
                      trailing: Switch(
                        value: isDarkMode,
                        activeThumbColor: AppColors.primary,
                        onChanged: (value) async {
                          await AppStateProvider().toggleTheme();
                          setState(() {});
                        },
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
                      title: "Barangay Help Desk",
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
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.textLight,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeaderCard() {
    final user = MockDatabaseService().currentUser;
    final name = user?.name ?? "Unknown User";
    final email = user?.email ?? "No email provided";
    final initials = name.isNotEmpty ? name[0].toUpperCase() : "?";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1628), Color(0xFF0D2040)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'avatar_profile',
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textLight),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.solved.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.solved.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.solved,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.solved.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Verified Resident",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.solved,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
      child: GestureDetector(
        onTap: () => _triggerEmergencyCall(agency, dialNum),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppColors.danger),
              const SizedBox(width: 7),
              Text(
                agency.split(' ')[0],
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerEmergencyCall(String target, String number) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(Icons.call, color: AppColors.danger, size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                "Emergency Dispatch",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Dial the official hotline for $target ($number) now?",
                style: const TextStyle(
                    color: AppColors.textLight, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text("Cancel",
                              style: TextStyle(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.call,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Connecting to $target ($number)...",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.surface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: AppColors.danger
                                      .withValues(alpha: 0.3)),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: AppColors.emergencyGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppColors.dangerGlowShadow,
                        ),
                        child: const Center(
                          child: Text(
                            "Call Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestructiveActionButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _triggerAccountActionDialog(
            "Logout",
            "Are you sure you want to exit your profile dashboard session safely?",
            false,
          ),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: AppColors.textLight, size: 18),
                SizedBox(width: 10),
                Text(
                  "Secure Dashboard Logout",
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _triggerAccountActionDialog(
            "Delete Profile Account",
            "CRITICAL WARNING: Purging your credentials wipes all location histories, filed safety status streams, and account backups completely. This is irreversible.",
            true,
          ),
          child: const Text(
            "Permanently Delete Citizen Account",
            style: TextStyle(
              color: AppColors.danger,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.danger,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
    final actionColor =
        isSevereDestructive ? AppColors.danger : AppColors.primary;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: actionColor.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: actionColor.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: actionColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  isSevereDestructive
                      ? Icons.delete_forever
                      : Icons.logout_rounded,
                  color: actionColor,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                contextTitle,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                briefMsg,
                style: const TextStyle(
                    color: AppColors.textLight, fontSize: 12, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text("Cancel",
                              style: TextStyle(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        if (contextTitle == "Logout") {
                          MockDatabaseService().logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WelcomePage()),
                            (route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Action '\$contextTitle' processed."),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: actionColor.withValues(alpha: 0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: actionColor.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              color: actionColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModalInformation(BuildContext ctx, String head, String paragraph) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  head,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              paragraph,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.primaryGlowShadow,
                ),
                child: const Center(
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
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
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppColors.primaryGlowShadow,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
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
                ?trailing,
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

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _savedAddressController;

  late String _selectedLanguage;
  bool _isSaving = false;

  final List<String> _languages = [
    'English',
    'Filipino',
  ];

  @override
  void initState() {
    super.initState();
    final user = MockDatabaseService().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emergencyContactController = TextEditingController(text: user?.emergencyContact ?? '');
    _savedAddressController = TextEditingController(text: user?.savedAddress ?? '');

    _selectedLanguage = (AppStateProvider().language == 'fil') ? 'Filipino' : 'English';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _savedAddressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final error = await MockDatabaseService().updateUserProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      emergencyContact: _emergencyContactController.text.trim(),
      savedAddress: _savedAddressController.text.trim(),
    );

    // Update language setting
    final newLangCode = _selectedLanguage == 'Filipino' ? 'fil' : 'en';
    await AppStateProvider().setLanguage(newLangCode);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.danger,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.tr('save_profile')),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MockDatabaseService().currentUser;
    final initials = (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: AppColors.primaryGlowShadow,
          ),
        ),
        title: Text(
          AppTranslations.tr('edit_profile_title'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
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
              /// AVATAR INTERFACE BLOCK (INITIALS FALLBACK)
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionSubHeader("Primary Credentials"),
              const SizedBox(height: 12),
              _buildValidatedField(
                controller: _nameController,
                label: AppTranslations.tr('full_name'),
                icon: Icons.person_outline_rounded,
                validator: (val) => val!.trim().isEmpty
                    ? "Full name is required"
                    : null,
              ),
              const SizedBox(height: 16),
              _buildValidatedField(
                controller: _emailController,
                label: AppTranslations.tr('email_address'),
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => !val!.contains('@')
                    ? "Valid email address required"
                    : null,
              ),
              const SizedBox(height: 16),
              _buildValidatedField(
                controller: _phoneController,
                label: AppTranslations.tr('mobile_number'),
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                validator: (val) => null, // Optional field
              ),

              const SizedBox(height: 24),
              _buildSectionSubHeader("Community Security Links"),
              const SizedBox(height: 12),
              _buildValidatedField(
                controller: _emergencyContactController,
                label: AppTranslations.tr('emergency_contact'),
                icon: Icons.contact_emergency_outlined,
                validator: (val) => null, // Optional field
              ),
              const SizedBox(height: 16),
              _buildValidatedField(
                controller: _savedAddressController,
                label: AppTranslations.tr('home_address'),
                icon: Icons.maps_home_work_outlined,
                validator: (val) => null, // Optional field
              ),
              const SizedBox(height: 16),

              /// REGIONAL LANGUAGE DROPDOWN (ENGLISH & FILIPINO ONLY)
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: InputDecoration(
                  labelText: AppTranslations.tr('app_language'),
                  prefixIcon: const Icon(
                    Icons.translate_rounded,
                    color: AppColors.textLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: _languages
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedLanguage = val);
                  }
                },
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.primaryGlowShadow,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            AppTranslations.tr('save_profile'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
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
        labelStyle: const TextStyle(color: AppColors.textLight),
        prefixIcon: Icon(icon, color: AppColors.textLight),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
        filled: true,
        fillColor: AppColors.surface,
        errorStyle: const TextStyle(fontWeight: FontWeight.bold),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(color: AppColors.textDark),
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
  bool _isChangingPass = false;

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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: AppColors.primaryGlowShadow,
          ),
        ),
        title: Text(
          AppTranslations.tr('privacy_security'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                AppTranslations.tr('update_password'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              subtitle: const Text(
                'Perform routine rotation changes for credentials protection',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              trailing:
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device Lock & Session Protection',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your sessions are protected via bcrypt hashing and JWT tokens. Hardware biometric authentication will be enabled in upcoming mobile builds.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textLight, height: 1.4),
                      ),
                    ],
                  ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
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
                Text(
                  AppTranslations.tr('update_password'),
                  style: const TextStyle(
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
                      ? "Current password is required"
                      : null,
                  decoration: InputDecoration(
                    labelText: AppTranslations.tr('current_password'),
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
                      ? "New password must be at least 6 characters"
                      : null,
                  decoration: InputDecoration(
                    labelText: AppTranslations.tr('new_password'),
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
                      ? "Passwords do not match"
                      : null,
                  decoration: InputDecoration(
                    labelText: AppTranslations.tr('confirm_password'),
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
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppColors.primaryGlowShadow,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isChangingPass
                          ? null
                          : () async {
                              if (_passFormKey.currentState!.validate()) {
                                setModalState(() => _isChangingPass = true);

                                final error = await MockDatabaseService().updateUserPassword(
                                  currentPassword: _currentPassCtrl.text,
                                  newPassword: _newPassCtrl.text,
                                );

                                setModalState(() => _isChangingPass = false);

                                if (error != null) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: AppColors.danger,
                                    ),
                                  );
                                } else {
                                  _currentPassCtrl.clear();
                                  _newPassCtrl.clear();
                                  _confirmPassCtrl.clear();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text("Password updated successfully!"),
                                      backgroundColor: AppColors.primary,
                                    ),
                                  );
                                }
                              }
                            },
                      child: _isChangingPass
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              AppTranslations.tr('save_password'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: AppColors.primaryGlowShadow,
          ),
        ),
        title: const Text(
          'Platform Legal Framework',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
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
                color: AppColors.primary,
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
        color: AppColors.surface,
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
              color: AppColors.primary,
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
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
