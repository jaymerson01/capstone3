import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/admin_data_service.dart';
import '../constants/admin_colors.dart';
import '../../widgets/custom_3d_card.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final dataService = AdminDataService();

  String searchQuery = "";
  String selectedRoleFilter = "All Roles";
  String selectedStatusFilter = "All Statuses";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataService.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final filteredUsers = dataService.users.where((user) {
          final matchesSearch = user.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
              user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
              user.role.toLowerCase().contains(searchQuery.toLowerCase());

          final matchesRole = selectedRoleFilter == "All Roles" ||
              user.role.toLowerCase() == selectedRoleFilter.toLowerCase();

          final matchesStatus = selectedStatusFilter == "All Statuses" ||
              (selectedStatusFilter == "Active" && user.isActive) ||
              (selectedStatusFilter == "Disabled" && !user.isActive);

          return matchesSearch && matchesRole && matchesStatus;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters Bar
              Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Search bar
                  SizedBox(
                    width: 300,
                    child: TextField(
                      style: const TextStyle(color: Color(0xFFE8F0FE), fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Search ID, name, email, role...",
                        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
                        filled: true,
                        fillColor: const Color(0xFF131F37),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF1E2D4A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF1E2D4A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 1.5),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),

                  // Role Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131F37),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1E2D4A)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF0D1627),
                        value: selectedRoleFilter,
                        style: const TextStyle(color: Color(0xFFE8F0FE), fontSize: 13, fontWeight: FontWeight.w600),
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0A84FF)),
                        items: ["All Roles", "User", "Admin", "Barangay Official", "Security Officer"]
                            .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedRoleFilter = val);
                        },
                      ),
                    ),
                  ),

                  // Status Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131F37),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1E2D4A)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF0D1627),
                        value: selectedStatusFilter,
                        style: const TextStyle(color: Color(0xFFE8F0FE), fontSize: 13, fontWeight: FontWeight.w600),
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0A84FF)),
                        items: ["All Statuses", "Active", "Disabled"]
                            .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedStatusFilter = val);
                        },
                      ),
                    ),
                  ),

                  // Show Archived Toggle
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Show Archived",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                      Switch(
                        value: dataService.showArchivedUsers,
                        activeThumbColor: const Color(0xFF0A84FF),
                        onChanged: (val) {
                          dataService.toggleArchivedUsers();
                        },
                      ),
                    ],
                  ),

                  // Refresh Button
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF0A84FF)),
                    tooltip: "Refresh Users List",
                    onPressed: () {
                      dataService.refreshData();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Users Table
              Expanded(
                child: Custom3dCard(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 22,
                  child: filteredUsers.isEmpty
                      ? const Center(
                          child: Text(
                            "No users found.",
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowHeight: 48,
                              columns: const [
                                DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE8F0FE)))),
                                DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE8F0FE)))),
                                DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE8F0FE)))),
                                DataColumn(label: Text("Role", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE8F0FE)))),
                                DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE8F0FE)))),
                                DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE8F0FE)))),
                              ],
                              rows: filteredUsers.map((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(user.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A84FF), fontSize: 12))),
                                    DataCell(Text(user.name, style: const TextStyle(color: Color(0xFFE8F0FE)))),
                                    DataCell(Text(user.email, style: const TextStyle(color: Color(0xFF94A3B8)))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0A84FF).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFF0A84FF).withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          user.role.toUpperCase(),
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0A84FF)),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (user.isActive ? const Color(0xFF34C759) : const Color(0xFFFF3B30)).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Text(
                                          user.isActive ? "Active" : "Disabled",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: user.isActive ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: Color(0xFF0A84FF), size: 18),
                                            tooltip: "Edit Role",
                                            onPressed: () {
                                              _showEditUserDialog(context, user);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              user.isActive ? Icons.block : Icons.check_circle_outline,
                                              color: user.isActive ? const Color(0xFFFF9500) : const Color(0xFF34C759),
                                              size: 18,
                                            ),
                                            tooltip: user.isActive ? "Disable User" : "Enable User",
                                            onPressed: () {
                                              dataService.toggleUserActive(user.id);
                                            },
                                          ),
                                          if (!user.isArchived)
                                            IconButton(
                                              icon: const Icon(Icons.archive_outlined, color: Color(0xFFFF3B30), size: 18),
                                              tooltip: "Archive User",
                                              onPressed: () {
                                                _confirmArchiveUser(context, user);
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
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmArchiveUser(BuildContext context, UserProfile user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1627),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF1E2D4A)),
          ),
          title: const Row(
            children: [
              Icon(Icons.archive_outlined, color: Color(0xFFFF3B30)),
              SizedBox(width: 10),
              Text("Archive User?", style: TextStyle(color: Color(0xFFE8F0FE), fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Are you sure you want to archive user '${user.name}' (${user.email})? Archived users are hidden from the active user directory.",
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                dataService.archiveUser(user.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("User '${user.name}' archived successfully."),
                    backgroundColor: const Color(0xFF131F37),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text("Archive User"),
            ),
          ],
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
              backgroundColor: const Color(0xFF0D1627),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF1E2D4A)),
              ),
              title: const Text("Edit User Role", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE8F0FE))),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${user.name}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE8F0FE))),
                    const SizedBox(height: 6),
                    Text("Email: ${user.email}", style: const TextStyle(color: Color(0xFF94A3B8))),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF0D1627),
                      value: ["user", "admin", "reporter", "barangay official", "security officer"].contains(selectedRole.toLowerCase())
                          ? selectedRole
                          : "user",
                      decoration: InputDecoration(
                        labelText: "User Role",
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFF131F37),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E2D4A))),
                      ),
                      style: const TextStyle(color: Color(0xFFE8F0FE)),
                      items: [
                        DropdownMenuItem(value: "user", child: Text("User")),
                        DropdownMenuItem(value: "admin", child: Text("Admin")),
                        DropdownMenuItem(value: "reporter", child: Text("Reporter")),
                        DropdownMenuItem(value: "barangay official", child: Text("Barangay Official")),
                        DropdownMenuItem(value: "security officer", child: Text("Security Officer")),
                      ],
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Color(0xFF94A3B8))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    dataService.updateUserRole(user.id, selectedRole);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("User role updated successfully"),
                        behavior: SnackBarBehavior.floating,
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

