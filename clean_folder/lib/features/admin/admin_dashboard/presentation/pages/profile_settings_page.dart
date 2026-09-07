import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_text_field.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    // Dummy values mimicking AdminDataService
    _nameController = TextEditingController(text: "Admin User");
    _emailController = TextEditingController(text: "admin@safe.gov");
    _passwordController = TextEditingController(text: "admin123");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Wire to AdminBloc / ProfileBloc
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Admin profile updated successfully! (UI Mock)"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _simulatePicUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Simulated profile picture upload completed!"),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SizedBox(
          width: 600,
          child: Custom3dCard(
            padding: const EdgeInsets.all(32),
            borderRadius: 24,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Admin Profile Settings",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AdminColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Configure your security credentials and profile parameters here.",
                    style: TextStyle(
                        fontSize: 13, color: AdminColors.textLight),
                  ),
                  const SizedBox(height: 30),

                  // Profile Image Simulator
                  Center(
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: AdminColors.primaryRose,
                          child: Text(
                            "A",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AdminColors.primaryRose,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                              onPressed: _simulatePicUpload,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "Click camera icon to change profile image",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Custom3dTextField(
                    controller: _nameController,
                    labelText: "Admin Display Name",
                    prefixIcon: Icons.person_outline,
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter display name"
                        : null,
                  ),

                  Custom3dTextField(
                    controller: _emailController,
                    labelText: "Login Email Address (Read-only)",
                    prefixIcon: Icons.email_outlined,
                  ),

                  Custom3dTextField(
                    controller: _passwordController,
                    labelText: "Account Password",
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter account password"
                        : null,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Custom3dButton(
                          icon: Icons.save_outlined,
                          text: "Save Changes",
                          onPressed: _saveProfile,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminColors.dangerRed,
                            side: const BorderSide(
                                color: AdminColors.dangerRed, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF0D1627),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(
                                        color: Color(0xFF1E2D4A))),
                                title: const Text("Confirm Logout",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                content: const Text(
                                    "Are you sure you want to log out of the admin panel?",
                                    style: TextStyle(
                                        color: Color(0xFF7B8DB0))),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel",
                                          style: TextStyle(
                                              color: Color(0xFF7B8DB0)))),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pushReplacementNamed(
                                          context, '/admin/login');
                                    },
                                    child: const Text("Logout",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text("Logout Portal",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
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
