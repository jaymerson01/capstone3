import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/core/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_header_parts.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/audit_log_remote_data_source.dart';
import 'package:community_safety_app/core/services/station_audio_service.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dutyStationController;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  bool _isTestingAudio = false;

  String? _currentPhotoUrl;
  String _currentUid = '';
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _dutyStationController = TextEditingController();

    _loadAdminProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dutyStationController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Fallback for offline demo mode
      setState(() {
        _nameController.text = "Barangay Admin";
        _emailController.text = "admin@safe.gov";
        _phoneController.text = "09170000911";
        _dutyStationController.text = "Barangay Moonwalk - Command Center";
        _isLoading = false;
      });
      return;
    }

    _currentUid = currentUser.uid;
    _emailController.text = currentUser.email ?? '';
    _nameController.text = currentUser.displayName ?? 'Barangay Admin';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        _nameController.text = (data['displayName'] as String?)?.isNotEmpty == true
            ? data['displayName']
            : (currentUser.displayName ?? 'Barangay Admin');
        _emailController.text = (data['email'] as String?) ?? (currentUser.email ?? '');
        _phoneController.text = (data['phoneNumber'] as String?) ?? '';
        _dutyStationController.text = (data['barangayArea'] as String?) ??
            'Barangay Moonwalk - Command Center';
        _currentPhotoUrl = data['photoUrl'] as String? ?? currentUser.photoURL;

        final ts = data['createdAt'] as Timestamp?;
        _createdAt = ts?.toDate();
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final bytes = await pickedFile.readAsBytes();
      const cloudName = AppConfig.cloudinaryCloudName;
      const uploadPreset = AppConfig.cloudinaryUploadPreset;

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'resq_admin_avatars'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'admin_avatar_${_currentUid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 40));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final secureUrl = data['secure_url'] as String?;

        if (secureUrl != null && secureUrl.isNotEmpty) {
          if (_currentUid.isNotEmpty) {
            await FirebaseFirestore.instance.collection('users').doc(_currentUid).update({
              'photoUrl': secureUrl,
            });
            await FirebaseAuth.instance.currentUser?.updatePhotoURL(secureUrl);
          }

          if (mounted) {
            setState(() {
              _currentPhotoUrl = secureUrl;
              _isUploadingPhoto = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AdminColors.cardBackground,
                behavior: SnackBarBehavior.floating,
                content: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AdminColors.success, size: 18),
                    SizedBox(width: 8),
                    Text("Profile picture updated successfully!",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          }
          return;
        }
      }
      throw Exception("Cloudinary server responded with status: ${response.statusCode}");
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AdminColors.dangerRed,
            content: Text("Failed to upload photo: $e"),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final dutyStation = _dutyStationController.text.trim();

      if (_currentUid.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(_currentUid).update({
          'displayName': name,
          'phoneNumber': phone,
          'barangayArea': dutyStation,
        });

        await FirebaseAuth.instance.currentUser?.updateDisplayName(name);

        final updatedUser = UserEntity(
          id: _currentUid,
          email: _emailController.text.trim(),
          displayName: name,
          role: 'admin',
          phoneNumber: phone,
          barangayArea: dutyStation,
          photoUrl: _currentPhotoUrl,
          isVerified: true,
          isActive: true,
          createdAt: _createdAt,
        );

        if (mounted) {
          context.read<AuthBloc>().add(UpdateProfileRequested(updatedUser));
        }

        try {
          await sl<AuditLogRemoteDataSource>().recordLog(
            actionType: 'Profile Update',
            details: 'Admin updated profile details ($name, duty station: $dutyStation)',
            targetId: _currentUid,
          );
        } catch (_) {}
      }

      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: AdminColors.cardBackground,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AdminColors.success, size: 18),
              SizedBox(width: 8),
              Text("Admin profile updated successfully!",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AdminColors.dangerRed,
          content: Text("Failed to update profile: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AdminColors.cardBackground,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            content: Row(
              children: [
                Icon(Icons.mark_email_read_rounded,
                    color: AdminColors.success, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Password reset link dispatched to $email! Please check your Gmail.",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AdminColors.dangerRed,
            content: Text("Error sending reset email: $e"),
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final passFormKey = GlobalKey<FormState>();
    final messenger = ScaffoldMessenger.of(context);
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AdminDialog(
          title: "Change Account Password",
          icon: Icons.lock_reset_rounded,
          tone: AdminTone.green,
          maxWidth: 480,
          actions: [
            AdminButton(
              label: "Cancel",
              style: AdminButtonStyle.ghost,
              onPressed: isUpdating ? null : () => Navigator.pop(dialogCtx),
            ),
            AdminButton(
              label: "Update Password",
              busy: isUpdating,
              onPressed: isUpdating
                  ? null
                  : () async {
                      if (!passFormKey.currentState!.validate()) return;
                      setDialogState(() => isUpdating = true);

                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null && user.email != null) {
                          final cred = EmailAuthProvider.credential(
                            email: user.email!,
                            password: currentPasswordController.text,
                          );
                          await user.reauthenticateWithCredential(cred);
                          await user.updatePassword(newPasswordController.text);

                          if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                          messenger.showSnackBar(
                            const SnackBar(
                              backgroundColor: AdminColors.cardBackground,
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                "Password updated successfully!",
                                style: TextStyle(color: AdminColors.success),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isUpdating = false);
                        messenger.showSnackBar(
                          SnackBar(
                            backgroundColor: AdminColors.dangerRed,
                            content: Text("Failed to change password: $e"),
                          ),
                        );
                      }
                    },
            ),
          ],
          child: Form(
            key: passFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AdminFieldLabel("Current Password"),
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  style: adminInputText,
                  decoration: adminInputDecoration(icon: Icons.lock_outline),
                  validator: (v) => v == null || v.isEmpty ? "Required." : null,
                ),
                const SizedBox(height: 14),
                const AdminFieldLabel("New Password"),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  style: adminInputText,
                  decoration: adminInputDecoration(icon: Icons.lock_open),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Required.";
                    if (v.length < 6) return "At least 6 characters required.";
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                const AdminFieldLabel("Confirm New Password"),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: adminInputText,
                  decoration: adminInputDecoration(
                    icon: Icons.check_circle_outline,
                  ),
                  validator: (v) {
                    if (v != newPasswordController.text) return "Passwords do not match.";
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _testStationAudio() {
    setState(() => _isTestingAudio = true);
    StationAudioService.testAlertSound(
      onComplete: () {
        if (mounted) {
          setState(() => _isTestingAudio = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AdminColors.cyan),
      );
    }

    final initial = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()[0].toUpperCase()
        : 'A';

    // ── 1. Avatar & Credentials + 2. Profile Details Form ────────────────
    final Widget identityPanel = AdminPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  // Leaves room for the camera button on the ring's edge.
                  Padding(
                    padding: const EdgeInsets.only(right: 4, bottom: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AdminColors.cyan.withValues(alpha: 0.6),
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: AdminColors.cyan.withValues(alpha: 0.3),
                            blurRadius: 22,
                          ),
                        ],
                      ),
                      child: _isUploadingPhoto
                          ? Container(
                              width: 84,
                              height: 84,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AdminColors.surfaceDeep,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AdminColors.cyan,
                                  ),
                                ),
                              ),
                            )
                          : AdminAvatar(
                              initial: initial,
                              photoUrl: _currentPhotoUrl,
                              size: 84,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                        customBorder: const CircleBorder(),
                        child: Ink(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: AdminColors.buttonGradient,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AdminColors.surfaceDeep,
                              width: 2,
                            ),
                            boxShadow: AdminColors.buttonShadow,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: AdminColors.textStrong,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.trim().isNotEmpty
                          ? _nameController.text
                          : "Municipal Administrator",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.textStrong,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _emailController.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AdminColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Non-technical Admin Badge
                    const AdminPill(
                      label: "Admin",
                      tone: AdminTone.blue,
                      icon: Icons.shield_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminSectionTitle(
                  title: "Administrator Identity & Contact",
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (_, constraints) {
                    // Two fields to a row when there is room for them.
                    final double fieldWidth = constraints.maxWidth >= 520
                        ? ((constraints.maxWidth - 14) / 2).floorToDouble()
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 14,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: fieldWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AdminFieldLabel("Display Name / Title"),
                              TextFormField(
                                controller: _nameController,
                                style: adminInputText,
                                decoration: adminInputDecoration(
                                  hint: "e.g. Dispatcher Juan",
                                  icon: Icons.badge_outlined,
                                ),
                                validator: (val) =>
                                    val == null || val.trim().isEmpty ? "Display name required." : null,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AdminFieldLabel(
                                "Registered Google Account Email",
                              ),
                              TextFormField(
                                controller: _emailController,
                                style: adminInputText,
                                decoration: adminInputDecoration(
                                  icon: Icons.email_outlined,
                                  suffix: const Icon(
                                    Icons.verified_user_rounded,
                                    color: AdminColors.successText,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7),
                              const Text(
                                "Authenticated & verified via Google Cloud Identity.",
                                style: TextStyle(
                                  color: AdminColors.textHint,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AdminFieldLabel(
                                "Desk Phone / Contact Number",
                              ),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: adminInputText,
                                decoration: adminInputDecoration(
                                  hint: "e.g. 0917 123 4567 / (02) 8800 1234",
                                  icon: Icons.phone_in_talk_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AdminFieldLabel(
                                "Command Center Duty Station",
                              ),
                              TextFormField(
                                controller: _dutyStationController,
                                style: adminInputText,
                                decoration: adminInputDecoration(
                                  hint:
                                      "e.g. Barangay Moonwalk - Command Center",
                                  icon: Icons.location_city_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                AdminButton(
                  icon: _isSaving ? null : Icons.save_rounded,
                  label: _isSaving ? "SAVING CHANGES..." : "SAVE PROFILE CHANGES",
                  busy: _isSaving,
                  height: 48,
                  debounce: true,
                  onPressed: _isSaving ? null : _saveProfile,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // ── 3. Security & Password Management ────────────────────────────────
    final Widget securityPanel = AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminSectionTitle(title: "Security & Credentials"),
          const SizedBox(height: 8),
          const Text(
            "Manage your login password or dispatch an official password reset link directly to your registered Google inbox.",
            style: TextStyle(
              fontSize: 12.5,
              color: AdminColors.textLight,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          AdminButton(
            label: "Send Reset Link to Gmail",
            icon: Icons.mark_email_read_outlined,
            style: AdminButtonStyle.ghost,
            expand: true,
            onPressed: _sendPasswordReset,
          ),
          const SizedBox(height: 10),
          AdminButton(
            label: "Change Password Directly",
            icon: Icons.password_rounded,
            style: AdminButtonStyle.ghost,
            expand: true,
            onPressed: _showChangePasswordDialog,
          ),
        ],
      ),
    );

    // ── 4. Station Audio & System Check ──────────────────────────────────
    final Widget audioPanel = AdminPanel(
      padding: EdgeInsets.zero,
      accent: AdminColors.dangerSoft,
      glow: true,
      // A faint red wash over the panel, as on the board.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AdminColors.critical.withValues(alpha: 0.12),
              AdminColors.critical.withValues(alpha: 0.04),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AdminSectionTitle(title: "Station Speaker & Audio Check"),
              const SizedBox(height: 8),
              const Text(
                "Verify that your command center desktop speakers are operational so you do not miss incoming citizen emergency alerts or siren broadcasts.",
                style: TextStyle(
                  fontSize: 12.5,
                  color: AdminColors.textLight,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              _RedOutlineButton(
                strong: true,
                icon: _isTestingAudio
                    ? Icons.volume_up_rounded
                    : Icons.play_arrow_rounded,
                label: _isTestingAudio
                    ? "PLAYING STATION SIREN CHIME..."
                    : "TEST STATION ALERT SOUND (resq_alert.wav)",
                onPressed: _testStationAudio,
              ),
            ],
          ),
        ),
      ),
    );

    // ── 5. Logout Option ─────────────────────────────────────────────────
    final Widget logoutButton = _RedOutlineButton(
      icon: Icons.logout_rounded,
      label: "Log Out of Admin Command Center",
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AdminDialog(
            title: "Confirm Logout",
            icon: Icons.logout_rounded,
            tone: AdminTone.red,
            maxWidth: 460,
            actions: [
              AdminButton(
                label: "Cancel",
                style: AdminButtonStyle.ghost,
                onPressed: () => Navigator.pop(ctx),
              ),
              AdminButton(
                label: "Log Out",
                style: AdminButtonStyle.danger,
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<AuthBloc>().add(const LogoutRequested());
                  Navigator.pushReplacementNamed(context, '/admin/login');
                },
              ),
            ],
            child: const Text(
              "Are you sure you want to log out of the municipal admin panel?",
              style: TextStyle(
                color: AdminColors.textSoft,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ),
        );
      },
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              const AdminPageTitle(
                title: "Admin Profile & Station Settings",
                subtitle:
                    "Manage your administrator credentials, duty station, and command audio settings.",
              ),
              const SizedBox(height: 22),

              // Identity on the left and the station tools on the right
              // when there is room, stacked otherwise. The children keep
              // their places either way, so the form is not rebuilt.
              LayoutBuilder(
                builder: (_, constraints) {
                  final bool sideBySide = constraints.maxWidth >= 860;
                  return Flex(
                    direction:
                        sideBySide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: sideBySide
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        flex: sideBySide ? 1 : 0,
                        fit: FlexFit.tight,
                        child: identityPanel,
                      ),
                      const SizedBox(width: 18, height: 18),
                      SizedBox(
                        width: 340,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            securityPanel,
                            const SizedBox(height: 18),
                            audioPanel,
                            const SizedBox(height: 18),
                            logoutButton,
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// The board's red outlined button. [strong] is the tinted station alert
/// test; otherwise it is the quieter log out.
class _RedOutlineButton extends StatelessWidget {
  const _RedOutlineButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.strong = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        strong ? AdminColors.dangerPale : AdminColors.dangerText;
    return Semantics(
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: strong
              ? AdminColors.critical.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AdminColors.dangerSoft.withValues(
              alpha: strong ? 0.7 : 0.35,
            ),
            width: strong ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18, color: foreground),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontSize: strong ? 12 : 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: strong ? 0.6 : 0,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
