import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';
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
        final filteredUsers = dataService.users.where((user) {
          return user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
              user.role.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: TextField(
                  style: const TextStyle(
                    color: AdminColors.textDark,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search users...",
                    hintStyle: const TextStyle(
                      color: AdminColors.textLight,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AdminColors.textLight,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(
                          label: Text(
                            "ID",
                            style: TextStyle(
                              color: AdminColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Name",
                            style: TextStyle(
                              color: AdminColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Email",
                            style: TextStyle(
                              color: AdminColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Role",
                            style: TextStyle(
                              color: AdminColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Status",
                            style: TextStyle(
                              color: AdminColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Actions",
                            style: TextStyle(
                              color: AdminColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      rows: filteredUsers.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                user.id,
                                style: const TextStyle(
                                  color: AdminColors.textDark,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: AdminColors.textDark,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                user.email,
                                style: const TextStyle(
                                  color: AdminColors.textDark,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                user.role,
                                style: const TextStyle(
                                  color: AdminColors.textDark,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                user.isActive ? "Active" : "Disabled",
                                style: TextStyle(
                                  color: user.isActive
                                      ? AdminColors.primaryGreen
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      _showEditUserDialog(context, user);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      user.isActive ? Icons.block : Icons.check,
                                      color: user.isActive
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                    onPressed: () {
                                      dataService.toggleUserActive(user.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      dataService.deleteUser(user.id);
                                    },
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
            ],
          ),
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, UserProfile user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                "Edit User Role",
                style: TextStyle(color: AdminColors.textDark),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name: ${user.name}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Email: ${user.email}",
                      style: const TextStyle(color: AdminColors.textDark),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        color: AdminColors.textDark,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        labelText: "User Role",
                        labelStyle: TextStyle(color: AdminColors.textLight),
                        border: OutlineInputBorder(),
                      ),
                      items:
                          [
                            "Reporter",
                            "Barangay Official",
                            "Security Officer",
                            "System Admin",
                          ].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedRole = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    dataService.updateUserRole(user.id, selectedRole);

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("User role updated successfully"),
                      ),
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
