import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/camera_service.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/emergency_hotlines_page.dart';


class SettingsPage extends StatefulWidget {
  final bool isRootTab;
  const SettingsPage({super.key, this.isRootTab = false});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserEntity? _lastKnownUser;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          height: 64 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: isDark ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (!widget.isRootTab) ...[
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                ],
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primary,
                        child: Icon(Icons.shield,
                            color: AppColors.textDark, size: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.cyanGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: const Text(
                    "SETTINGS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.tune_rounded,
                      color: AppColors.primary, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  /// 1. DYNAMIC PROFILE HEADER CARD
                  _buildProfileHeaderCard(),
                  SizedBox(height: 24),

                  /// 2. EMERGENCY SERVICES
                  _buildSectionTitle("Emergency Services"),
                  SizedBox(height: 12),
                  _buildSettingTile(
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: AppColors.danger,
                    title: "Barangay Emergency Hotlines",
                    subtitle: "Police (911), Fire (112), Medical (143) & BDRRMC",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyHotlinesPage(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  /// 3. ACCOUNT SETTINGS
                  _buildSectionTitle("Account Settings"),
                  SizedBox(height: 12),
                  _buildSettingTile(
                    icon: Icons.person_outline_rounded,
                    title: "Edit Personal Details",
                    subtitle: "Full name, mobile number, sector & home address",
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
                    subtitle: "Update account credentials & view anti-spam security policy",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacySecurityPage(user: _lastKnownUser),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  /// APP PREFERENCES
                  _buildSectionTitle("App Preferences"),
                  SizedBox(height: 12),
                  ValueListenableBuilder<bool>(
                    valueListenable: AppColors.isDarkModeNotifier,
                    builder: (context, isDark, child) {
                      return _buildSettingTile(
                        icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        title: "App Theme",
                        subtitle: isDark ? "Dark Mode" : "Light Mode",
                        trailing: Switch(
                          value: isDark,
                          onChanged: (value) {
                            AppColors.isDarkMode = value;
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                        onTap: () {
                          AppColors.isDarkMode = !isDark;
                        },
                      );
                    },
                  ),


                  /// 5. SUPPORT & CIVIC INFORMATION
                  _buildSectionTitle("Support & Information"),
                  SizedBox(height: 12),
                  _buildSettingTile(
                    icon: Icons.info_outline_rounded,
                    title: "About ResQ Community Safety",
                    subtitle: "Platform guidelines, emergency mandates & version",
                    onTap: () => _showModalInformation(
                      context,
                      "About ResQ Community Safety",
                      "ResQ Community Safety is a civic-tech emergency response platform connecting residents with the Barangay Command Operations Center for rapid incident dispatch, verification, and community resilience.",
                    ),
                  ),
                  _buildSettingTile(
                    icon: Icons.headset_mic_outlined,
                    title: "Barangay Help Desk",
                    subtitle: "Contact municipal administrative support team",
                    onTap: () => _showBarangayHelpDesk(context),
                  ),
                  _buildSettingTile(
                    icon: Icons.rate_review_outlined,
                    title: "Submit App Feedback & Bug Report",
                    subtitle: "Report issues or suggest platform improvements",
                    onTap: () => _showFeedbackDialog(context),
                  ),
                  SizedBox(height: 28),

                  /// 5. DESTRUCTIVE ACTIONS
                  _buildDestructiveActionButtons(),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // Persistent Footer
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 16,
                top: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ResQ Community Safety",
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "v1.0.0 Production",
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
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
        SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: TextStyle(
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          _lastKnownUser = authState.user;
        }

        final UserEntity? user = (authState is Authenticated ? authState.user : null) ?? _lastKnownUser;

        final String name = user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : "Resident Citizen";
        final String email = user?.email.isNotEmpty == true
            ? user!.email
            : "demo@resident.ph";
        final String sector = user?.barangayArea?.isNotEmpty == true
            ? user!.barangayArea!
            : "Area 1 - San Jose";
        final bool isVerified = user?.isVerified ?? true;
        final String? photoUrl = user?.photoUrl;

        String initials = "R";
        if (name.trim().isNotEmpty) {
          final parts = name.trim().split(' ');
          if (parts.length >= 2) {
            initials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
          } else {
            initials = parts[0][0].toUpperCase();
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? (photoUrl.startsWith('http')
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Center(
                                child: Text(
                                  initials,
                                  style: TextStyle(color: AppColors.textDark,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            )
                          : Image.file(
                              File(photoUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Center(
                                child: Text(
                                  initials,
                                  style: TextStyle(color: AppColors.textDark,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ))
                      : Center(
                          child: Text(
                            initials,
                            style: TextStyle(color: AppColors.textDark,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(width: 16),

              // User Meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Verified Badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 7),
                    // Location & Verification Metadata
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            sector,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.textLight.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isVerified ? "Verified Resident" : "Resident Citizen",
                          style: TextStyle(
                            fontSize: 11,
                            color: isVerified ? AppColors.solved : AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick Edit Icon
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDestructiveActionButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _triggerAccountActionDialog(
            "Log Out",
            "Are you sure you want to log out of your ResQ resident account?",
            false,
          ),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppColors.textLight, size: 18),
                SizedBox(width: 10),
                Text(
                  "Log Out",
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
        SizedBox(height: 12),
        TextButton(
          onPressed: () => _triggerAccountActionDialog(
            "Delete Account",
            "Warning: Deleting your resident account permanently clears all filed report logs and saved profile information. This action is irreversible.",
            true,
          ),
          child: Text(
            "Permanently Delete Account",
            style: TextStyle(
              color: AppColors.danger,
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: actionColor.withValues(alpha: 0.12),
                ),
                child: Icon(
                  isSevereDestructive
                      ? Icons.delete_forever_rounded
                      : Icons.logout_rounded,
                  color: actionColor,
                  size: 28,
                ),
              ),
              SizedBox(height: 16),
              Text(
                contextTitle,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                briefMsg,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(ctx);
                        if (contextTitle == "Log Out") {
                          context.read<AuthBloc>().add(const LogoutRequested());
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomePage(),
                            ),
                            (route) => false,
                          );
                        } else {
                          // Permanently Delete Account (RA 10173 Compliance)
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("No active resident session found."),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          try {
                            final uid = user.uid;
                            // 1. Delete resident profile in Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .delete();

                            // 2. Delete user account in Firebase Auth
                            await user.delete();

                            if (!mounted) return;
                            context.read<AuthBloc>().add(const LogoutRequested());
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WelcomePage(),
                              ),
                              (route) => false,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Your account and personal data have been permanently erased (RA 10173).",
                                ),
                                backgroundColor: AppColors.solved,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            if (!mounted) return;
                            if (e.code == 'requires-recent-login') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Security Alert: Account deletion requires recent authentication. Please log out, sign in again, and retry.",
                                  ),
                                  backgroundColor: AppColors.warning,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 5),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Account deletion failed: ${e.message}",
                                  ),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error deleting account: $e"),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: actionColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isSevereDestructive ? "Delete" : "Confirm",
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
      shape: RoundedRectangleBorder(
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
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    head,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Text(
              paragraph,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textLight,
              ),
            ),
            SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.primaryGlowShadow,
                ),
                child: Center(
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: AppColors.textDark,
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

  void _showBarangayHelpDesk(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
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
              SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Barangay Administrative Help Desk",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Barangay Moonwalk, Parañaque City",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildHelpDeskRow(
                      Icons.location_on_rounded,
                      "Office Address",
                      "Armstrong Ave., Moonwalk, Parañaque City",
                    ),
                    Divider(color: AppColors.border, height: 20),
                    _buildHelpDeskRow(
                      Icons.access_time_rounded,
                      "Public Service Hours",
                      "Monday – Friday: 8:00 AM – 5:00 PM",
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final uri = Uri(scheme: 'tel', path: '0288288041');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: Icon(Icons.phone, size: 18),
                      label: Text(
                        "Call Office",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textDark,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final uri = Uri(
                          scheme: 'mailto',
                          path: 'admin@moonwalk.resq.ph',
                          query: 'subject=Barangay%20Moonwalk%20Citizen%20Inquiry',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: Icon(Icons.email_outlined, size: 18),
                      label: Text(
                        "Send Email",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "For immediate life-threatening emergencies (Fire, Police, Medical), please use the Emergency Hotlines or submit an incident report.",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        height: 1.3,
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

  Widget _buildHelpDeskRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textLight),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackCtrl = TextEditingController();
    String selectedCategory = "General Feedback";
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.border),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rate_review_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Submit App Feedback",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Help us improve ResQ for Barangay Moonwalk. Your feedback is sent directly to the development team.",
                  style: TextStyle(fontSize: 12.5, color: AppColors.textLight, height: 1.4),
                ),
                SizedBox(height: 14),
                Text(
                  "FEEDBACK CATEGORY",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    "General Feedback",
                    "Bug Report",
                    "Feature Suggestion",
                  ].map((cat) {
                    final isSelected = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.textLight,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.background,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setDialogState(() => selectedCategory = cat);
                        }
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 14),
                TextField(
                  controller: feedbackCtrl,
                  maxLines: 4,
                  style: TextStyle(color: AppColors.textDark, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Describe your feedback, suggestion, or bug encounter...",
                    hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textLight),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: Text("Cancel", style: TextStyle(color: AppColors.textLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final text = feedbackCtrl.text.trim();
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please write a short description before submitting."),
                            backgroundColor: AppColors.warning,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);
                      final messenger = ScaffoldMessenger.of(context);

                      try {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        await FirebaseFirestore.instance.collection('app_feedback').add({
                          'userId': _lastKnownUser?.id ?? currentUser?.uid ?? 'anonymous',
                          'userName': _lastKnownUser?.displayName ?? currentUser?.displayName ?? 'Resident',
                          'userEmail': _lastKnownUser?.email ?? currentUser?.email ?? '',
                          'category': selectedCategory,
                          'message': text,
                          'createdAt': FieldValue.serverTimestamp(),
                          'appVersion': '1.0.0',
                        });

                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text("Thank you! Your feedback has been submitted to the technical team."),
                            backgroundColor: AppColors.solved,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text("Failed to submit feedback: $e"),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppColors.textDark,
                        strokeWidth: 2,
                      ),
                    )
                  : Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final effectiveColor = iconColor ?? AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: effectiveColor),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
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
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textLight,
                    size: 13,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= SUB PAGE: EDIT RESIDENT PROFILE =================
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
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _emergencyContactNumberController;
  late TextEditingController _savedAddressController;

  String _selectedBarangay = 'Area 1 - San Jose';
  String _selectedLanguage = 'English (PH)';
  File? _selectedAvatarFile;
  bool _isSaving = false;

  final List<String> _barangayList = [
    'Area 1 - San Jose',
    'Area 2 - Santo Nino',
    'Area 3 - Santa Cruz',
    'Area 4 - Moonwalk Core',
    'Area 5 - Phase 1 & 2',
    'Area 6 - Multinational Village',
  ];

  final List<String> _languages = [
    'English (PH)',
    'Filipino (Tagalog)',
  ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final UserEntity? user = authState is Authenticated ? authState.user : null;

    _nameController = TextEditingController(
      text: user?.displayName ?? 'Juan Dela Cruz',
    );
    _emailController = TextEditingController(
      text: user?.email ?? 'demo@resident.ph',
    );
    _phoneController = TextEditingController(
      text: user?.phoneNumber ?? '09171234567',
    );
    _emergencyContactNameController = TextEditingController(
      text: user?.emergencyContactName ?? 'Maria Dela Cruz',
    );
    _emergencyContactNumberController = TextEditingController(
      text: user?.emergencyContactNumber ?? '09198887766',
    );
    _savedAddressController = TextEditingController(
      text: user?.address ?? 'Bldg 4, St. Francis Compound, Moonwalk',
    );

    if (user?.barangayArea != null &&
        _barangayList.contains(user!.barangayArea)) {
      _selectedBarangay = user.barangayArea!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactNumberController.dispose();
    _savedAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile Photo",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: Text(
                "Take Photo with Camera",
                style: TextStyle(color: AppColors.textDark, fontSize: 14),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final file =
                    await sl<CameraService>().pickImageFromCamera();
                if (file != null) {
                  setState(() => _selectedAvatarFile = file);
                }
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: Text(
                "Choose from Gallery",
                style: TextStyle(color: AppColors.textDark, fontSize: 14),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final file =
                    await sl<CameraService>().pickImageFromGallery();
                if (file != null) {
                  setState(() => _selectedAvatarFile = file);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfileChanges() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authState = context.read<AuthBloc>().state;
      final UserEntity? currentUser =
          authState is Authenticated ? authState.user : null;

      String? photoUrl = currentUser?.photoUrl;
      if (_selectedAvatarFile != null) {
        photoUrl =
            await sl<CameraService>().uploadImage(_selectedAvatarFile!);
      }

      final updatedUser = (currentUser ??
              const UserEntity(
                id: 'resident_demo_01',
                email: 'demo@resident.ph',
              ))
          .copyWith(
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _savedAddressController.text.trim(),
        barangayArea: _selectedBarangay,
        emergencyContactName: _emergencyContactNameController.text.trim(),
        emergencyContactNumber:
            _emergencyContactNumberController.text.trim(),
        photoUrl: photoUrl,
      );

      if (!mounted) return;
      context.read<AuthBloc>().add(UpdateProfileRequested(updatedUser));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile details updated successfully!"),
          backgroundColor: AppColors.solved,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final UserEntity? user =
        authState is Authenticated ? authState.user : null;
    final existingPhoto = user?.photoUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
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
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _selectedAvatarFile != null
                            ? Image.file(_selectedAvatarFile!, fit: BoxFit.cover)
                            : (existingPhoto != null && existingPhoto.isNotEmpty
                                ? (existingPhoto.startsWith('http')
                                    ? Image.network(
                                        existingPhoto,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) =>
                                            Icon(Icons.person,
                                                size: 54,
                                                color: AppColors.primary),
                                      )
                                    : Image.file(
                                        File(existingPhoto),
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) =>
                                            Icon(Icons.person,
                                                size: 54,
                                                color: AppColors.primary),
                                      ))
                                : Icon(
                                    Icons.person,
                                    size: 54,
                                    color: AppColors.primary,
                                  )),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAvatarImage,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            border: Border.all(
                                color: AppColors.background, width: 2),
                            boxShadow: AppColors.primaryGlowShadow,
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28),

              _buildSectionSubHeader("Personal Credentials"),
              SizedBox(height: 12),
              _buildValidatedField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person_outline_rounded,
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Please enter your full name"
                    : null,
              ),
              SizedBox(height: 14),

              // Email (Read-only credential)
              TextFormField(
                controller: _emailController,
                readOnly: true,
                style: TextStyle(color: AppColors.textLight),
                decoration: InputDecoration(
                  labelText: "Email Address (Account ID)",
                  labelStyle: TextStyle(color: AppColors.textLight),
                  prefixIcon:
                      Icon(Icons.email_outlined, color: AppColors.textLight),
                  suffixIcon:
                      Icon(Icons.lock_outline, color: AppColors.textLight, size: 16),
                  helperText: "Primary login credential cannot be changed",
                  helperStyle:
                      TextStyle(color: AppColors.textLight, fontSize: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  filled: true,
                  fillColor: AppColors.surface.withValues(alpha: 0.6),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 14),

              _buildValidatedField(
                controller: _phoneController,
                label: "Mobile Phone Number",
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().length < 7
                    ? "Please enter a valid mobile number"
                    : null,
              ),

              SizedBox(height: 24),
              _buildSectionSubHeader("Barangay Jurisdiction & Address"),
              SizedBox(height: 12),

              /// BARANGAY SECTOR DROPDOWN
              DropdownButtonFormField<String>(
                initialValue: _selectedBarangay,
                dropdownColor: AppColors.surface,
                isExpanded: true,
                style: TextStyle(color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: "Barangay Area / Sector",
                  labelStyle: TextStyle(color: AppColors.textLight),
                  prefixIcon: Icon(
                    Icons.holiday_village_outlined,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: _barangayList
                    .map((b) => DropdownMenuItem(
                          value: b,
                          child: Text(
                            b,
                            style: TextStyle(color: AppColors.textDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBarangay = val);
                },
              ),
              SizedBox(height: 14),

              _buildValidatedField(
                controller: _savedAddressController,
                label: "Residential Address / House Details",
                icon: Icons.home_work_outlined,
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Please enter your residential address"
                    : null,
              ),

              SizedBox(height: 24),
              _buildSectionSubHeader("Emergency Contact Fallback"),
              SizedBox(height: 12),

              _buildValidatedField(
                controller: _emergencyContactNameController,
                label: "Emergency Contact Person",
                icon: Icons.contact_emergency_outlined,
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Please provide an emergency contact person"
                    : null,
              ),
              SizedBox(height: 14),

              _buildValidatedField(
                controller: _emergencyContactNumberController,
                label: "Emergency Contact Number",
                icon: Icons.phone_in_talk_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().length < 7
                    ? "Please provide an emergency contact phone number"
                    : null,
              ),

              SizedBox(height: 24),
              _buildSectionSubHeader("Language Preference"),
              SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _selectedLanguage,
                dropdownColor: AppColors.surface,
                isExpanded: true,
                style: TextStyle(color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: "App Interface Language",
                  labelStyle: TextStyle(color: AppColors.textLight),
                  prefixIcon: Icon(
                    Icons.translate_rounded,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: _languages
                    .map((l) => DropdownMenuItem(
                          value: l,
                          child: Text(
                            l,
                            style: TextStyle(color: AppColors.textDark),
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
              ),

              SizedBox(height: 36),

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
                      foregroundColor: AppColors.textDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveProfileChanges,
                    child: _isSaving
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.textDark,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'SAVE PROFILE CHANGES',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionSubHeader(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
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
      style: TextStyle(color: AppColors.textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textLight),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.surface,
        errorStyle: TextStyle(color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ================= SUB PAGE: PRIVACY & SECURITY =================
class PrivacySecurityPage extends StatefulWidget {
  final UserEntity? user;
  const PrivacySecurityPage({super.key, this.user});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isHardwareSupported = false;

  @override
  void initState() {
    super.initState();
    _checkHardware();
  }

  Future<void> _checkHardware() async {
    bool canCheck = false;
    bool isDeviceSupported = false;
    try {
      canCheck = await _localAuth.canCheckBiometrics;
      isDeviceSupported = await _localAuth.isDeviceSupported();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isHardwareSupported = canCheck || isDeviceSupported;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Privacy & Security',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
            'Credentials & Access',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: 12),

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
                child: Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                'Change Account Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                'Update password for resident account credentials',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color: AppColors.textLight,
              ),
              onTap: () => _displayChangePasswordSheet(context),
            ),
          ),

          SizedBox(height: 28),
          Text(
            'Civic Security & Anti-Spam Policy',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.solved.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.solved,
                    size: 22,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Biometric Verification',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.solved.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ENFORCED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.solved,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        _isHardwareSupported
                            ? 'Biometric confirmation (fingerprint or face authentication) is enforced by Barangay Moonwalk municipal policy when submitting emergency reports to deter false alarms and prank filings.'
                            : 'Hardware biometrics not detected on this device. Device PIN or secure credential confirmation will serve as anti-spam verification.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                          height: 1.45,
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

  void _displayChangePasswordSheet(BuildContext ctx) {
    final passFormKey = GlobalKey<FormState>();
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.border),
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
            key: passFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please enter your current password followed by your new password.',
                  style: TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: currentPassCtrl,
                  obscureText: obscureCurrent,
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  validator: (val) => val == null || val.isEmpty
                      ? "Please enter your current password"
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: TextStyle(color: AppColors.textLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                      onPressed: () => setModalState(
                        () => obscureCurrent = !obscureCurrent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14),

                TextFormField(
                  controller: newPassCtrl,
                  obscureText: obscureNew,
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  validator: (val) => val == null || val.length < 6
                      ? "Password must be at least 6 characters"
                      : null,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: AppColors.textLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                      onPressed: () =>
                          setModalState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                SizedBox(height: 14),

                TextFormField(
                  controller: confirmPassCtrl,
                  obscureText: obscureConfirm,
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  validator: (val) => val != newPassCtrl.text
                      ? "Passwords do not match"
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: TextStyle(color: AppColors.textLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                      onPressed: () => setModalState(
                        () => obscureConfirm = !obscureConfirm,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      final email = widget.user?.email ?? FirebaseAuth.instance.currentUser?.email;
                      if (email == null || email.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text("No registered email found for this account."),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Password reset link sent to $email. Please check your email inbox to reset your password.",
                            ),
                            backgroundColor: AppColors.solved,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text("Failed to send reset email: $e"),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.mail_outline_rounded, size: 14, color: AppColors.primary),
                    label: Text(
                      "Forgot current password? Send reset link to email",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 48,
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
                        foregroundColor: AppColors.textDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (!passFormKey.currentState!.validate()) return;
                              setModalState(() => isSubmitting = true);

                              final result = await sl<AuthRepository>()
                                  .changePassword(
                                currentPassCtrl.text,
                                newPassCtrl.text,
                              );

                              if (!context.mounted) return;

                              result.fold(
                                (failure) {
                                  setModalState(() => isSubmitting = false);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Password change failed: ${failure.message}"),
                                      backgroundColor: AppColors.danger,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                (_) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Password updated successfully!"),
                                      backgroundColor: AppColors.solved,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              );
                            },
                      child: isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.textDark,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'UPDATE PASSWORD',
                              style: TextStyle(
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
      ),
    );
  }
}
