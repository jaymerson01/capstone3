import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/neo/aurora_background.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/neo_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_chip.dart';
import 'package:community_safety_app/core/presentation/neo/neo_dialog.dart';
import 'package:community_safety_app/core/presentation/neo/neo_icon_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_sheet.dart';
import 'package:community_safety_app/core/presentation/neo/neo_status_pill.dart';
import 'package:community_safety_app/core/presentation/neo/neo_surface.dart';
import 'package:community_safety_app/core/presentation/neo/neo_tray.dart';
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
import 'package:community_safety_app/core/theme/app_theme.dart';


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
        final l10n = AppLocalizations.of(context);
        // A root tab sits on the shell's aurora; a pushed page brings its own.
        final page = Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                24 + (widget.isRootTab ? 0 : MediaQuery.paddingOf(context).bottom),
              ),
              children: [
                // Header
                Row(
                  children: [
                    if (!widget.isRootTab) ...[
                      NeoIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: l10n.commonBack,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        l10n.settingsTitle,
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),

                /// 1. DYNAMIC PROFILE HEADER CARD
                _buildProfileHeaderCard(),
                SizedBox(height: 22),

                /// 2. EMERGENCY SERVICES
                _buildSectionTitle(l10n.settingsEmergencyServices),
                _buildSettingsGroup([
                  _buildSettingTile(
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: AppColors.danger,
                    title: l10n.settingsHotlinesTitle,
                    subtitle: l10n.settingsHotlinesSubtitle,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyHotlinesPage(),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 22),

                /// 3. ACCOUNT SETTINGS
                _buildSectionTitle(l10n.settingsAccount),
                _buildSettingsGroup([
                  _buildSettingTile(
                    icon: Icons.person_outline_rounded,
                    title: l10n.settingsEditProfile,
                    subtitle: l10n.settingsEditProfileSubtitle,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    ),
                  ),
                  _buildSettingTile(
                    icon: Icons.shield_outlined,
                    title: l10n.settingsPrivacy,
                    subtitle: l10n.settingsPrivacySubtitle,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacySecurityPage(user: _lastKnownUser),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 22),

                /// APP PREFERENCES
                _buildSectionTitle(l10n.settingsPreferences),
                _buildSettingsGroup([
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
                ]),
                SizedBox(height: 22),

                /// 5. SUPPORT & CIVIC INFORMATION
                _buildSectionTitle(l10n.settingsSupport),
                _buildSettingsGroup([
                  _buildSettingTile(
                    icon: Icons.info_outline_rounded,
                    title: l10n.settingsAbout,
                    subtitle: l10n.settingsAboutSubtitle,
                    onTap: () => _showModalInformation(
                      context,
                      l10n.settingsAbout,
                      l10n.settingsAboutBody,
                    ),
                  ),
                  _buildSettingTile(
                    icon: Icons.headset_mic_outlined,
                    title: l10n.settingsHelpDesk,
                    subtitle: l10n.settingsHelpDeskSubtitle,
                    onTap: () => _showBarangayHelpDesk(context),
                  ),
                  _buildSettingTile(
                    icon: Icons.rate_review_outlined,
                    title: l10n.settingsFeedback,
                    subtitle: l10n.settingsFeedbackSubtitle,
                    onTap: () => _showFeedbackDialog(context),
                  ),
                ]),
                SizedBox(height: 26),

                /// 5. DESTRUCTIVE ACTIONS
                _buildDestructiveActionButtons(),
                SizedBox(height: 16),

                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ResQ Community Safety",
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
        return widget.isRootTab ? page : AuroraBackground(child: page);
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// A section's rows on one glass card, with hairlines between them.
  Widget _buildSettingsGroup(List<Widget> tiles) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 22,
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: AppColors.border.withValues(alpha: 0.6),
              ),
            tiles[i],
          ],
        ],
      ),
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

        final initialsText = Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        );

        return NeoTray(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF5B6578), Color(0xFF394254)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.6),
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? (photoUrl.startsWith('http')
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => initialsText,
                            )
                          : Image.file(
                              File(photoUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => initialsText,
                            ))
                      : initialsText,
                ),
              ),
              SizedBox(width: 14),

              // User Meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: NeoTray.soft,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Location & Verification Metadata
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.secondaryLight,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            sector,
                            style: const TextStyle(
                              fontSize: 12,
                              color: NeoTray.soft,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isVerified ? AppColors.secondary : Colors.white)
                            .withValues(alpha: isVerified ? 0.16 : 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isVerified) ...[
                            Icon(Icons.verified_rounded,
                                size: 12, color: AppColors.secondaryLight),
                            const SizedBox(width: 5),
                          ],
                          Flexible(
                            child: Text(
                              isVerified ? AppLocalizations.of(context).settingsVerifiedResident : AppLocalizations.of(context).settingsResidentCitizen,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isVerified ? AppColors.secondaryLight : NeoTray.soft,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Edit Icon
              NeoIconButton(
                icon: Icons.edit_outlined,
                tooltip: AppLocalizations.of(context).settingsEditProfile,
                tone: NeoIconButtonTone.slate,
                size: 40,
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
    final logOutColor =
        AppColors.isDarkMode ? AppColors.dangerLight : AppColors.dangerDeep;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: TextButton.icon(
            onPressed: () => _triggerAccountActionDialog(
              AppLocalizations.of(context).settingsLogOut,
              AppLocalizations.of(context).settingsLogOutConfirm,
              false,
            ),
            style: ButtonStyle(
              backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
              foregroundColor: WidgetStatePropertyAll(logOutColor),
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              shape: const WidgetStatePropertyAll(StadiumBorder()),
              textStyle: const WidgetStatePropertyAll(
                TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              backgroundBuilder: NeoSurface.background(NeoFill.raised),
            ),
            clipBehavior: Clip.none,
            icon: Icon(Icons.logout_rounded, size: 18),
            label: Text(AppLocalizations.of(context).settingsLogOut),
          ),
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: () => _triggerAccountActionDialog(
            AppLocalizations.of(context).settingsDeleteAccount,
            AppLocalizations.of(context).settingsDeleteWarning,
            true,
          ),
          child: Text(
            AppLocalizations.of(context).settingsDeleteForever,
            style: TextStyle(
              color: logOutColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
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
      builder: (ctx) => NeoDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeoDialogIcon(
              icon: isSevereDestructive
                  ? Icons.delete_forever_rounded
                  : Icons.logout_rounded,
              color: actionColor,
            ),
            SizedBox(height: 16),
            Text(
              contextTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              briefMsg,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 13.5,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: AppLocalizations.of(context).commonCancel,
                    variant: NeoButtonVariant.standard,
                    height: 48,
                    expand: true,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: NeoButton(
                    label: isSevereDestructive ? AppLocalizations.of(context).commonDelete : AppLocalizations.of(context).commonConfirm,
                    variant: isSevereDestructive
                        ? NeoButtonVariant.emergency
                        : NeoButtonVariant.primary,
                    height: 48,
                    expand: true,
                    onPressed: () async {
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A sheet heading: a tinted icon tile and the title.
  Widget _buildSheetHeader(IconData icon, String title, {String? subtitle}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: AppColors.isDarkMode ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppColors.primaryText, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showModalInformation(BuildContext ctx, String head, String paragraph) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (context) => NeoSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetHeader(Icons.info_outline_rounded, head),
            SizedBox(height: 14),
            Text(
              paragraph,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.6,
                color: AppColors.textLight,
              ),
            ),
            SizedBox(height: 22),
            NeoButton(
              label: AppLocalizations.of(context).commonClose,
              expand: true,
              height: 50,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showBarangayHelpDesk(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (context) => NeoSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetHeader(
              Icons.account_balance_rounded,
              AppLocalizations.of(context).settingsHelpDeskTitle,
              subtitle: "Barangay Moonwalk, Parañaque City",
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: NeoSurface.inset(radius: 18),
              child: Column(
                children: [
                  _buildHelpDeskRow(
                    Icons.location_on_rounded,
                    AppLocalizations.of(context).settingsOfficeAddress,
                    "Armstrong Ave., Moonwalk, Parañaque City",
                  ),
                  Divider(color: AppColors.border.withValues(alpha: 0.7), height: 20),
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
                  child: NeoButton(
                    label: AppLocalizations.of(context).settingsCallOffice,
                    icon: Icons.phone_rounded,
                    variant: NeoButtonVariant.standard,
                    height: 48,
                    expand: true,
                    onPressed: () async {
                      final uri = Uri(scheme: 'tel', path: '0288288041');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: NeoButton(
                    label: AppLocalizations.of(context).settingsSendEmail,
                    icon: Icons.email_outlined,
                    height: 48,
                    expand: true,
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
                      fontSize: 11.5,
                      color: AppColors.textLight,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpDeskRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryText),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5,
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
        builder: (ctx, setDialogState) => NeoDialog(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSheetHeader(
                  Icons.rate_review_rounded,
                  AppLocalizations.of(context).settingsFeedbackTitle,
                ),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).settingsFeedbackIntro,
                  style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.4),
                ),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).settingsFeedbackCategory,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
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
                    return NeoChip(
                      label: _feedbackCategoryLabel(context, cat),
                      selected: selectedCategory == cat,
                      onPressed: () {
                        setDialogState(() => selectedCategory = cat);
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: feedbackCtrl,
                  maxLines: 4,
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  decoration: _insetDecoration(
                    hint: AppLocalizations.of(context).settingsFeedbackHint,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: NeoButton(
                        label: AppLocalizations.of(context).commonCancel,
                        variant: NeoButtonVariant.standard,
                        height: 48,
                        expand: true,
                        onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _PillProgressButton(
                        label: AppLocalizations.of(context).commonSubmit,
                        busy: isSubmitting,
                        height: 48,
                        onPressed: () async {
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final current = LocaleController.locale;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NeoSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetHeader(
              Icons.translate_rounded,
              AppLocalizations.of(ctx).languageSettingTitle,
            ),
            SizedBox(height: 12),
            for (final locale in AppLocalizations.supportedLocales)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Icon(
                  locale == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: AppColors.primaryText,
                ),
                title: Text(
                  LocaleController.displayName(locale),
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: locale == current ? FontWeight.w800 : FontWeight.w600,
                  ),
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
    final isDark = AppColors.isDarkMode;
    // Emergency rows get a red tile; the rest a sunken one with a blue icon.
    final emergency = iconColor != null;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: emergency
                    ? BoxDecoration(
                        gradient: AppColors.emergencyGradient,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.danger.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      )
                    : NeoSurface.inset(radius: 13),
                child: Icon(
                  icon,
                  size: 19,
                  color: emergency ? Colors.white : AppColors.primaryText,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.textLight : const Color(0xFF475569),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sunken text-field decoration shared by the Settings forms.
InputDecoration _insetDecoration({
  String? label,
  String? hint,
  String? helper,
  IconData? icon,
  Widget? suffix,
}) {
  final isDark = AppColors.isDarkMode;
  final radius = BorderRadius.circular(16);
  final edge = isDark ? AppColors.glassBorder : const Color(0xFFE2E8F0);
  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helper,
    labelStyle: TextStyle(color: AppColors.textLight),
    hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
    helperStyle: TextStyle(color: AppColors.textLight, fontSize: 11),
    prefixIcon: icon == null
        ? null
        : Icon(icon, color: AppColors.primaryText, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: isDark ? const Color(0xFF0F1830) : const Color(0xFFEEF2F7),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: edge)),
    enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: edge)),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
    ),
    errorStyle: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
  );
}

/// The blue pill action that shows a spinner while [busy].
class _PillProgressButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onPressed;
  final double height;

  const _PillProgressButton({
    required this.label,
    required this.busy,
    required this.onPressed,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: AppColors.primaryGlowShadow,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white70,
            shape: const StadiumBorder(),
          ),
          onPressed: busy ? null : onPressed,
          child: busy
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              // Shrinks to fit rather than cutting the label off.
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// A Settings sub-page: the aurora, a header with Back and the title, then
/// [child] below.
class _NeoSubPage extends StatelessWidget {
  final String title;
  final Widget child;

  const _NeoSubPage({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: [
                    NeoIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: AppLocalizations.of(context).commonBack,
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
            ],
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
      backgroundColor: Colors.transparent,
      builder: (ctx) => NeoSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).profilePhotoTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 12),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Icon(Icons.camera_alt_rounded,
                  color: AppColors.primaryText),
              title: Text(
                AppLocalizations.of(context).profileTakePhoto,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading:
                  Icon(Icons.photo_library_rounded, color: AppColors.primaryText),
              title: Text(
                AppLocalizations.of(context).profileChooseGallery,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
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
    final fallbackAvatar = Icon(Icons.person, size: 54, color: AppColors.primaryText);

    return _NeoSubPage(
      title: AppLocalizations.of(context).profileTitle,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.paddingOf(context).bottom),
        child: Form(
          key: _profileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        color: AppColors.surfaceLight,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 18,
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
                                            fallbackAvatar,
                                      )
                                    : Image.file(
                                        File(existingPhoto),
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) =>
                                            fallbackAvatar,
                                      ))
                                : fallbackAvatar),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAvatarImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: AppColors.primaryGlowShadow,
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              _buildSectionSubHeader(AppLocalizations.of(context).profileCredentials),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
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
                      style: TextStyle(color: AppColors.textLight, fontSize: 14),
                      decoration: _insetDecoration(
                        label: AppLocalizations.of(context).profileEmailLabel,
                        icon: Icons.email_outlined,
                        suffix: Icon(Icons.lock_outline, color: AppColors.textLight, size: 16),
                        helper: AppLocalizations.of(context).profileEmailHelper,
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
                  ],
                ),
              ),

              SizedBox(height: 22),
              _buildSectionSubHeader(AppLocalizations.of(context).profileJurisdiction),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// BARANGAY SECTOR DROPDOWN
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBarangay,
                      dropdownColor: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      isExpanded: true,
                      style: TextStyle(color: AppColors.textDark,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _insetDecoration(
                        label: AppLocalizations.of(context).profileAreaLabel,
                        icon: Icons.holiday_village_outlined,
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
                  ],
                ),
              ),

              SizedBox(height: 22),
              _buildSectionSubHeader(AppLocalizations.of(context).profileEmergencyContact),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
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
                  ],
                ),
              ),

              SizedBox(height: 28),

              _PillProgressButton(
                label: AppLocalizations.of(context).profileSave,
                busy: _isSaving,
                onPressed: _saveProfileChanges,
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionSubHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.textLight,
        ),
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
      decoration: _insetDecoration(label: label, icon: icon),
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

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    return _NeoSubPage(
      title: AppLocalizations.of(context).privacyTitle,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          _buildSectionLabel(AppLocalizations.of(context).privacyCredentials),
          GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: 22,
            onTap: () => _displayChangePasswordSheet(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: NeoSurface.inset(radius: 13),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.primaryText,
                      size: 19,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).privacyChangePassword,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context).privacyChangePasswordSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: isDark ? AppColors.textLight : const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),
          _buildSectionLabel(AppLocalizations.of(context).privacyPolicyTitle),

          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.solved.withValues(alpha: isDark ? 0.22 : 0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: isDark ? Color.lerp(AppColors.solved, Colors.white, 0.35) : AppColors.solved,
                    size: 21,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context).privacyBiometric,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.textDark,
                            ),
                          ),
                          NeoStatusPill(
                            label: AppLocalizations.of(context).privacyEnforced,
                            color: AppColors.solved,
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        _isHardwareSupported
                            ? AppLocalizations.of(context).privacyBiometricOn
                            : AppLocalizations.of(context).privacyBiometricOff,
                        style: TextStyle(
                          fontSize: 12.5,
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

    Widget visibilityToggle(bool obscure, VoidCallback onPressed) {
      return IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textLight,
          size: 20,
        ),
        onPressed: onPressed,
      );
    }

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: NeoSheet(
            child: Form(
              key: passFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context).passwordDialogTitle,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context).passwordDialogIntro,
                    style: TextStyle(fontSize: 12.5, color: AppColors.textLight, height: 1.4),
                  ),
                  SizedBox(height: 18),

                  TextFormField(
                    controller: currentPassCtrl,
                    obscureText: obscureCurrent,
                    style: TextStyle(color: AppColors.textDark, fontSize: 14),
                    validator: (val) => val == null || val.isEmpty
                        ? AppLocalizations.of(context).passwordCurrentRequired
                        : null,
                    decoration: _insetDecoration(
                      label: AppLocalizations.of(context).passwordCurrentLabel,
                      suffix: visibilityToggle(
                        obscureCurrent,
                        () => setModalState(
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
                    decoration: _insetDecoration(
                      label: AppLocalizations.of(context).passwordNewLabel,
                      suffix: visibilityToggle(
                        obscureNew,
                        () => setModalState(() => obscureNew = !obscureNew),
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
                    decoration: _insetDecoration(
                      label: AppLocalizations.of(context).passwordConfirmLabel,
                      suffix: visibilityToggle(
                        obscureConfirm,
                        () => setModalState(
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
                      icon: Icon(Icons.mail_outline_rounded, size: 15, color: AppColors.primaryText),
                      label: Text(
                        AppLocalizations.of(context).passwordForgot,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  _PillProgressButton(
                    label: AppLocalizations.of(context).passwordUpdateButton,
                    busy: isSubmitting,
                    height: 50,
                    onPressed: () async {
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
