import 'package:flutter/material.dart';
import '../services/admin_data_service.dart';
import '../constants/admin_colors.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final dataService = AdminDataService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: dataService.adminName);
    _emailController = TextEditingController(text: dataService.adminEmail);
    _passwordController = TextEditingController(text: dataService.adminPassword);
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
      dataService.updateProfile(
        name: _nameController.text.trim(),
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin profile updated successfully!")),
      );
    }
  }

  void _simulatePicUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Simulated profile picture upload completed!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
            border: Border.all(color: AdminColors.border),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Admin Profile Settings",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Configure your security credentials and profile parameters here.",
                  style: TextStyle(fontSize: 13, color: AdminColors.textLight),
                ),
                const SizedBox(height: 30),

                // Profile Image Simulator
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AdminColors.primaryGreen,
                        child: const Text(
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
                          backgroundColor: AdminColors.primaryGreen,
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
                const SizedBox(height: 35),

                // Name field
                const Text(
                  "Admin Display Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AdminColors.textDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AdminColors.border),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty ? "Enter display name" : null,
                ),
                const SizedBox(height: 20),

                // Email field (read-only for security)
                const Text(
                  "Login Email Address (Read-only)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AdminColors.textDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AdminColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password field
                const Text(
                  "Account Password",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AdminColors.textDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AdminColors.border),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty ? "Enter account password" : null,
                ),
                const SizedBox(height: 35),

                // Action Buttons layout
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdminColors.dangerRed,
                          side: const BorderSide(color: AdminColors.dangerRed),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirm Logout"),
                              content: const Text("Are you sure you want to log out of the admin panel?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pushReplacementNamed(context, '/admin/login'); // Redirect to login
                                  },
                                  child: const Text("Logout", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text("Logout Portal", style: TextStyle(fontWeight: FontWeight.bold)),
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
}
