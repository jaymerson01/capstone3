import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/admin_data_service.dart';
import '../constants/admin_colors.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final dataService = AdminDataService();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        // Search filter matching name, email, or role
        final filteredUsers = dataService.users.where((user) {
          return user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
              user.role.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Control
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search users by name, email, or role...",
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AdminColors.border),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            searchQuery = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Quick stats tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AdminColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Total Registered: ${dataService.registeredUsers}",
                        style: const TextStyle(
                          color: AdminColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Users Table
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: filteredUsers.isEmpty
                        ? const Center(
                            child: Text(
                              "No users found matching search criteria.",
                              style: TextStyle(color: AdminColors.textLight, fontSize: 15),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(AdminColors.primaryGreen.withOpacity(0.05)),
                                columnSpacing: 45,
                                columns: const [
                                  DataColumn(label: Text("User ID", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Account Role", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: filteredUsers.map((user) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(user.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text(user.name)),
                                      DataCell(Text(user.email)),
                                      DataCell(Text(user.role)),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: user.isActive 
                                                ? AdminColors.solvedGreen.withOpacity(0.15) 
                                                : Colors.grey.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            user.isActive ? "Active" : "Disabled",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: user.isActive ? AdminColors.solvedGreen : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            // Edit dialog trigger
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                              tooltip: "Edit User",
                                              onPressed: () => _showEditUserDialog(context, user),
                                            ),
                                            // Enable/Disable toggle trigger
                                            IconButton(
                                              icon: Icon(
                                                user.isActive ? Icons.block : Icons.check_circle_outline,
                                                color: user.isActive ? Colors.orange : Colors.green,
                                                size: 20,
                                              ),
                                              tooltip: user.isActive ? "Disable User" : "Enable User",
                                              onPressed: () {
                                                dataService.toggleUserActive(user.id);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      user.isActive 
                                                          ? "User account successfully disabled" 
                                                          : "User account successfully enabled"
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            // Delete trigger
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: AdminColors.dangerRed, size: 20),
                                              tooltip: "Delete User",
                                              onPressed: () => _confirmDeleteUser(context, user),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Edit user detail dialog
  void _showEditUserDialog(BuildContext context, UserProfile user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Edit User Profile: ${user.id}"),
              content: SizedBox(
                width: 450,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Full Name"),
                        validator: (val) => val == null || val.isEmpty ? "Enter full name" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "Email Address"),
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Enter email address";
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                            return "Enter a valid email format";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(labelText: "Account Role"),
                        items: ["Reporter", "Barangay Official", "Security Officer", "System Admin"].map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedRole = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primaryGreen, foregroundColor: Colors.white),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updated = user.copyWith(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        role: selectedRole,
                      );
                      dataService.editUser(updated);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User profile successfully updated")),
                      );
                    }
                  },
                  child: const Text("Save Changes"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Confirm delete user dialog popup
  void _confirmDeleteUser(BuildContext context, UserProfile user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete User"),
          content: Text("Are you sure you want to permanently delete user account '${user.name}'? This will delete all record associations."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.dangerRed, foregroundColor: Colors.white),
              onPressed: () {
                dataService.deleteUser(user.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("User '${user.name}' deleted successfully")),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
