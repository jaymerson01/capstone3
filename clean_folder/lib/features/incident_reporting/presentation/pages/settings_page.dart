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
import 'package:community_safety_app/core/services/locale_controller.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/emergency_hotlines_page.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';


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
                  child: Text(
                    AppLocalizations.of(context).settingsTitle,
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
                  _buildSectionTitle(AppLocalizations.of(context).settingsEmergencyServices),
                  SizedBox(height: 12),
                  _buildSettingTile(
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: AppColors.danger,
                    title: AppLocalizations.of(context).settingsHotlinesTitle,
                    subtitle: AppLocalizations.of(context).settingsHotlinesSubtitle,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyHotlinesPage(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  /// 3. ACCOUNT SETTINGS
                  _buildSectionTitle(AppLocalizations.of(context).settingsAccount),
                  SizedBox(height: 12),
                  _buildSettingTile(
                    icon: Icons.person_outline_rounded,
                    title: AppLocalizations.of(context).settingsEditProfile,
                    subtitle: AppLocalizations.of(context).settingsEditProfileSubtitle,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    ),
                  ),
                  _buildSettingTile(
                    icon: Icons.shield_outlined,
                    title: AppLocalizations.of(context).settingsPrivacy,
                    subtitle: AppLocalizations.of(context).settingsPrivacySubtitle,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacySecurityPage(user: _lastKnownUser),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  /// APP PREFERENCES
                  _buildSectionTitle(AppLocalizations.of(context).settingsPreferences),
                  SizedBox(height: 12),
                  ValueListenableBuilder<bool>(
                    valueListenable: AppColors.isDarkModeNotifier,
                    builder: (context, isDark, child) {
                      return _buildSettingTile(
                        icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        title: AppLocalizations.of(context).settingsTheme,
                        subtitle: isDark ? AppLocalizations.of(context).settingsDarkMode : AppLocalizations.of(context).settingsLightMode,
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
                  ValueListenableBuilder<Locale>(
                    valueListenable: LocaleController.localeNotifier,
                    builder: (context, locale, child) {
                      return _buildSettingTile(
                        icon: Icons.translate_rounded,
                        title: AppLocalizations.of(context).languageSettingTitle,
                        subtitle: LocaleController.displayName(locale),
                        onTap: () => _showLanguagePicker(context),
                      );
                    },
                  ),


                  /// 5. SUPPORT & CIVIC INFORMATION
                  _buildSectionTitle(AppLocalizations.of(context).settingsSupport),
                  SizedBox(height: 12),
                  _buildSettingTile(
                    icon: Icons.info_outline_rounded,
                    title: AppLocalizations.of(context).settingsAbout,
                    subtitle: AppLocalizations.of(context).settingsAboutSubtitle,
                    onTap: () => _showModalInformation(
                      context,
                      AppLocalizations.of(context).settingsAbout,
                      AppLocalizations.of(context).settingsAboutBody,
                    ),
                  ),
                  _buildSettingTile(
                    icon: Icons.headset_mic_outlined,
                    title: AppLocalizations.of(context).settingsHelpDesk,
                    subtitle: AppLocalizations.of(context).settingsHelpDeskSubtitle,
                    onTap: () => _showBarangayHelpDesk(context),
                  ),
                  _buildSettingTile(
                    icon: Icons.rate_review_outlined,
                    title: AppLocalizations.of(context).settingsFeedback,
                    subtitle: AppLocalizations.of(context).settingsFeedbackSubtitle,
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
            : AppLocalizations.of(context).settingsResidentCitizen;
        final String email = user?.email.isNotEmpty == true
            ? user!.email
            : "";
        final String sector = user?.barangayArea?.isNotEmpty == true
            ? user!.barangayArea!
            : AppLocalizations.of(context).settingsSectorNotSet;
        final bool isVerified = user?.isVerified ?? false;
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
                          isVerified ? AppLocalizations.of(context).settingsVerifiedResident : AppLocalizations.of(context).settingsResidentCitizen,
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
            AppLocalizations.of(context).settingsLogOut,
            AppLocalizations.of(context).settingsLogOutConfirm,
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
                  AppLocalizations.of(context).settingsLogOut,
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
            AppLocalizations.of(context).settingsDeleteAccount,
            AppLocalizations.of(context).settingsDeleteWarning,
            true,
          ),
          child: Text(
            AppLocalizations.of(context).settingsDeleteForever,
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
                            AppLocalizations.of(context).commonCancel,
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
                        if (!isSevereDestructive) {
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
                              SnackBar(
                                content: Text(AppLocalizations.of(context).settingsNoSession),
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
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context).settingsAccountErased,
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
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context).settingsRecentLoginRequired,
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
                                    AppLocalizations.of(context).settingsDeleteFailed(LocalizedLabels.authError(
                                      context,
                                      code: e.code,
                                      message: e.message ?? e.code,
                                    )),
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
                                content: Text(AppLocalizations.of(context).settingsDeleteError('$e')),
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
                            isSevereDestructive ? AppLocalizations.of(context).commonDelete : AppLocalizations.of(context).commonConfirm,
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
                    AppLocalizations.of(context).commonClose,
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
                          AppLocalizations.of(context).settingsHelpDeskTitle,
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
                      AppLocalizations.of(context).settingsOfficeAddress,
                      "Armstrong Ave., Moonwalk, Parañaque City",
                    ),
                    Divider(color: AppColors.border, height: 20),
                    _buildHelpDeskRow(
                      Icons.access_time_rounded,
                      AppLocalizations.of(context).settingsServiceHours,
                      AppLocalizations.of(context).settingsServiceHoursValue,
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
                        AppLocalizations.of(context).settingsCallOffice,
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
                        AppLocalizations.of(context).settingsSendEmail,
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
                      AppLocalizations.of(context).settingsHelpDeskNote,
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

  /// The English category is what gets saved; this is only what residents see.
  String _feedbackCategoryLabel(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case "General Feedback":
        return l10n.feedbackGeneral;
      case "Bug Report":
        return l10n.feedbackBug;
      case "Feature Suggestion":
        return l10n.feedbackFeature;
      default:
        return category;
    }
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
                AppLocalizations.of(context).settingsFeedbackTitle,
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
                  AppLocalizations.of(context).settingsFeedbackIntro,
                  style: TextStyle(fontSize: 12.5, color: AppColors.textLight, height: 1.4),
                ),
                SizedBox(height: 14),
                Text(
                  AppLocalizations.of(context).settingsFeedbackCategory,
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
                        _feedbackCategoryLabel(context, cat),
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
                    hintText: AppLocalizations.of(context).settingsFeedbackHint,
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
              child: Text(AppLocalizations.of(context).commonCancel, style: TextStyle(color: AppColors.textLight)),
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
                          SnackBar(
                            content: Text(AppLocalizations.of(context).settingsFeedbackEmpty),
                            backgroundColor: AppColors.warning,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);
                      final messenger = ScaffoldMessenger.of(context);
                      final l10n = AppLocalizations.of(context);

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
                          SnackBar(
                            content: Text(l10n.settingsFeedbackThanks),
                            backgroundColor: AppColors.solved,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.settingsFeedbackFailed('$e')),
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
                  : Text(AppLocalizations.of(context).commonSubmit),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final current = LocaleController.locale;
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
              AppLocalizations.of(ctx).languageSettingTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 16),
            for (final locale in AppLocalizations.supportedLocales)
              ListTile(
                leading: Icon(
                  locale == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  LocaleController.displayName(locale),
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  LocaleController.setLocale(locale);
                },
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

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final UserEntity? user = authState is Authenticated ? authState.user : null;

    _nameController = TextEditingController(
      text: user?.displayName ?? '',
    );
    _emailController = TextEditingController(
      text: user?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: user?.phoneNumber ?? '',
    );
    _emergencyContactNameController = TextEditingController(
      text: user?.emergencyContactName ?? '',
    );
    _emergencyContactNumberController = TextEditingController(
      text: user?.emergencyContactNumber ?? '',
    );
    _savedAddressController = TextEditingController(
      text: user?.address ?? '',
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
              AppLocalizations.of(context).profilePhotoTitle,
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
                AppLocalizations.of(context).profileTakePhoto,
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
                AppLocalizations.of(context).profileChooseGallery,
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
        SnackBar(
          content: Text(AppLocalizations.of(context).profileUpdated),
          backgroundColor: AppColors.solved,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).profileUpdateFailed('$e')),
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
          AppLocalizations.of(context).profileTitle,
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

              _buildSectionSubHeader(AppLocalizations.of(context).profileCredentials),
              SizedBox(height: 12),
              _buildValidatedField(
                controller: _nameController,
                label: AppLocalizations.of(context).signUpNameLabel,
                icon: Icons.person_outline_rounded,
                validator: (val) => val == null || val.trim().isEmpty
                    ? AppLocalizations.of(context).profileNameRequired
                    : null,
              ),
              SizedBox(height: 14),

              // Email (Read-only credential)
              TextFormField(
                controller: _emailController,
                readOnly: true,
                style: TextStyle(color: AppColors.textLight),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).profileEmailLabel,
                  labelStyle: TextStyle(color: AppColors.textLight),
                  prefixIcon:
                      Icon(Icons.email_outlined, color: AppColors.textLight),
                  suffixIcon:
                      Icon(Icons.lock_outline, color: AppColors.textLight, size: 16),
                  helperText: AppLocalizations.of(context).profileEmailHelper,
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
                label: AppLocalizations.of(context).profilePhoneLabel,
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().length < 7
                    ? AppLocalizations.of(context).profilePhoneInvalid
                    : null,
              ),

              SizedBox(height: 24),
              _buildSectionSubHeader(AppLocalizations.of(context).profileJurisdiction),
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
                  labelText: AppLocalizations.of(context).profileAreaLabel,
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
                label: AppLocalizations.of(context).profileAddressLabel,
                icon: Icons.home_work_outlined,
                validator: (val) => val == null || val.trim().isEmpty
                    ? AppLocalizations.of(context).profileAddressRequired
                    : null,
              ),

              SizedBox(height: 24),
              _buildSectionSubHeader(AppLocalizations.of(context).profileEmergencyContact),
              SizedBox(height: 12),

              _buildValidatedField(
                controller: _emergencyContactNameController,
                label: AppLocalizations.of(context).profileContactName,
                icon: Icons.contact_emergency_outlined,
                validator: (val) => val == null || val.trim().isEmpty
                    ? AppLocalizations.of(context).profileContactNameRequired
                    : null,
              ),
              SizedBox(height: 14),

              _buildValidatedField(
                controller: _emergencyContactNumberController,
                label: AppLocalizations.of(context).profileContactNumber,
                icon: Icons.phone_in_talk_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().length < 7
                    ? AppLocalizations.of(context).profileContactNumberInvalid
                    : null,
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
                            AppLocalizations.of(context).profileSave,
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
          AppLocalizations.of(context).privacyTitle,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
            AppLocalizations.of(context).privacyCredentials,
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
                AppLocalizations.of(context).privacyChangePassword,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(context).privacyChangePasswordSubtitle,
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
            AppLocalizations.of(context).privacyPolicyTitle,
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
                            AppLocalizations.of(context).privacyBiometric,
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
                              AppLocalizations.of(context).privacyEnforced,
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
                            ? AppLocalizations.of(context).privacyBiometricOn
                            : AppLocalizations.of(context).privacyBiometricOff,
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
                  AppLocalizations.of(context).passwordDialogTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).passwordDialogIntro,
                  style: TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: currentPassCtrl,
                  obscureText: obscureCurrent,
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  validator: (val) => val == null || val.isEmpty
                      ? AppLocalizations.of(context).passwordCurrentRequired
                      : null,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).passwordCurrentLabel,
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
                      ? AppLocalizations.of(context).passwordMinLength
                      : null,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).passwordNewLabel,
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
                      ? AppLocalizations.of(context).passwordMismatchShort
                      : null,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).passwordConfirmLabel,
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
                          SnackBar(
                            content: Text(AppLocalizations.of(context).passwordNoEmail),
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
                              AppLocalizations.of(context).passwordResetSent(email),
                            ),
                            backgroundColor: AppColors.solved,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).passwordResetFailed('$e')),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.mail_outline_rounded, size: 14, color: AppColors.primary),
                    label: Text(
                      AppLocalizations.of(context).passwordForgot,
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
                                          AppLocalizations.of(context).passwordChangeFailed(LocalizedLabels.authError(
                                            context,
                                            code: failure.code,
                                            message: failure.message,
                                          ))),
                                      backgroundColor: AppColors.danger,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                (_) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context).passwordUpdated),
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
                              AppLocalizations.of(context).passwordUpdateButton,
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
