import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_text_field.dart';
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
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'g45cmboy';
      final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'crkjnmhd';

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
                backgroundColor: Color(0xFF0D1627),
                behavior: SnackBarBehavior.floating,
                content: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF30D158), size: 18),
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
          backgroundColor: Color(0xFF0D1627),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF30D158), size: 18),
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
            backgroundColor: const Color(0xFF0D1627),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            content: Row(
              children: [
                Icon(Icons.mark_email_read_rounded,
                    color: Color(0xFF30D158), size: 18),
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
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0D1627),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF1E2D4A)),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: Color(0xFF30D158), size: 22),
              SizedBox(width: 10),
              Text(
                "Change Account Password",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Form(
            key: passFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Custom3dTextField(
                  controller: currentPasswordController,
                  labelText: "Current Password",
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? "Required." : null,
                ),
                Custom3dTextField(
                  controller: newPasswordController,
                  labelText: "New Password",
                  prefixIcon: Icons.lock_open,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Required.";
                    if (v.length < 6) return "At least 6 characters required.";
                    return null;
                  },
                ),
                Custom3dTextField(
                  controller: confirmPasswordController,
                  labelText: "Confirm New Password",
                  prefixIcon: Icons.check_circle_outline,
                  obscureText: true,
                  validator: (v) {
                    if (v != newPasswordController.text) return "Passwords do not match.";
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : () => Navigator.pop(dialogCtx),
              child: Text("Cancel", style: TextStyle(color: Color(0xFF7B8DB0))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF30D158),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
                              backgroundColor: Color(0xFF0D1627),
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                "Password updated successfully!",
                                style: TextStyle(color: Color(0xFF30D158)),
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
              child: isUpdating
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Text("Update Password",
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
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
      return Center(
        child: CircularProgressIndicator(color: AdminColors.primaryGreen),
      );
    }

    final initial = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()[0].toUpperCase()
        : 'A';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Card ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF30D158).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF30D158).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Color(0xFF30D158),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Admin Profile & Station Settings",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AdminColors.textDark,
                            letterSpacing: 0.4,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Manage your administrator credentials, duty station, and command audio settings.",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AdminColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // ── 1. Avatar & Credentials Card ────────────────────────
              Custom3dCard(
                padding: const EdgeInsets.all(28),
                borderRadius: 22,
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF30D158), Color(0xFF0A84FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF30D158).withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(3.5),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0D1627),
                              ),
                              child: ClipOval(
                                child: _isUploadingPhoto
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Color(0xFF30D158),
                                        ),
                                      )
                                    : (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty
                                        ? Image.network(
                                            _currentPhotoUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) => Center(
                                              child: Text(
                                                initial,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 38,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              initial,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 38,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF30D158),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF0D1627), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.camera_alt_rounded,
                                    size: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _nameController.text.trim().isNotEmpty
                          ? _nameController.text
                          : "Municipal Administrator",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _emailController.text,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AdminColors.textLight,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Non-technical Admin Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF30D158).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF30D158).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, color: Color(0xFF30D158), size: 14),
                          SizedBox(width: 5),
                          Text(
                            "Admin",
                            style: TextStyle(
                              color: Color(0xFF30D158),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // ── 2. Profile Details Form ──────────────────────────────
              Custom3dCard(
                padding: const EdgeInsets.all(28),
                borderRadius: 22,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Administrator Identity & Contact",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AdminColors.textDark,
                        ),
                      ),
                      SizedBox(height: 18),

                      Custom3dTextField(
                        controller: _nameController,
                        labelText: "Display Name / Title",
                        hintText: "e.g. Dispatcher Juan",
                        prefixIcon: Icons.badge_outlined,
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? "Display name required." : null,
                      ),

                      Custom3dTextField(
                        controller: _emailController,
                        labelText: "Registered Google Account Email",
                        prefixIcon: Icons.email_outlined,
                      ),
                      SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.verified_user_rounded,
                                color: Color(0xFF30D158), size: 14),
                            SizedBox(width: 6),
                            Text(
                              "Authenticated & verified via Google Cloud Identity.",
                              style: TextStyle(
                                color: Color(0xFF30D158),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Custom3dTextField(
                        controller: _phoneController,
                        labelText: "Desk Phone / Contact Number",
                        hintText: "e.g. 0917 123 4567 / (02) 8800 1234",
                        prefixIcon: Icons.phone_in_talk_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      Custom3dTextField(
                        controller: _dutyStationController,
                        labelText: "Command Center Duty Station",
                        hintText: "e.g. Barangay Moonwalk - Command Center",
                        prefixIcon: Icons.location_city_outlined,
                      ),

                      SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: Custom3dButton(
                          icon: _isSaving ? null : Icons.save_rounded,
                          text: _isSaving ? "SAVING CHANGES..." : "SAVE PROFILE CHANGES",
                          gradient: AppColors.primaryGradient,
                          onPressed: _isSaving ? null : _saveProfile,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // ── 3. Security & Password Management ────────────────────
              Custom3dCard(
                padding: const EdgeInsets.all(26),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security_rounded, color: Color(0xFF0A84FF), size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Security & Credentials",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AdminColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Manage your login password or dispatch an official password reset link directly to your registered Google inbox.",
                      style: TextStyle(fontSize: 12.5, color: AdminColors.textLight, height: 1.4),
                    ),
                    SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0A84FF),
                              side: const BorderSide(color: Color(0xFF0A84FF), width: 1.3),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: Icon(Icons.mark_email_read_outlined, size: 18),
                            label: Text(
                              "Send Reset Link to Gmail",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                            onPressed: _sendPasswordReset,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF30D158),
                              side: const BorderSide(color: Color(0xFF30D158), width: 1.3),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: Icon(Icons.password_rounded, size: 18),
                            label: Text(
                              "Change Password Directly",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                            onPressed: _showChangePasswordDialog,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // ── 4. Station Audio & System Check ──────────────────────
              Custom3dCard(
                padding: const EdgeInsets.all(26),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.volume_up_rounded, color: Color(0xFFFF9500), size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Station Speaker & Audio Check",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AdminColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Verify that your command center desktop speakers are operational so you do not miss incoming citizen emergency alerts or siren broadcasts.",
                      style: TextStyle(fontSize: 12.5, color: AdminColors.textLight, height: 1.4),
                    ),
                    SizedBox(height: 16),

                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF9500),
                        side: const BorderSide(color: Color(0xFFFF9500), width: 1.3),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(
                        _isTestingAudio ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                        size: 20,
                      ),
                      label: Text(
                        _isTestingAudio
                            ? "PLAYING STATION SIREN CHIME..."
                            : "TEST STATION ALERT SOUND (resq_alert.wav)",
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                      ),
                      onPressed: _testStationAudio,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // ── 5. Logout Option ─────────────────────────────────────
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AdminColors.dangerRed,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: Icon(Icons.logout_rounded, size: 18),
                  label: Text(
                    "Log Out of Admin Command Center",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF0D1627),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFF1E2D4A)),
                        ),
                        title: Text("Confirm Logout",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        content: Text(
                          "Are you sure you want to log out of the municipal admin panel?",
                          style: TextStyle(color: Color(0xFF7B8DB0)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text("Cancel", style: TextStyle(color: Color(0xFF7B8DB0))),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AuthBloc>().add(const LogoutRequested());
                              Navigator.pushReplacementNamed(context, '/admin/login');
                            },
                            child: Text("Log Out",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
