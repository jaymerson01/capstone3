import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String searchQuery = "";
  bool showArchivedUsers = false;

  // Dummy data representing state from BLoC
  final List<Map<String, dynamic>> _dummyUsers = [
    {
      'id': 'U-1001',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'role': 'Reporter',
      'isActive': true,
    },
    {
      'id': 'U-1002',
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'role': 'Barangay Official',
      'isActive': true,
    },
    {
      'id': 'U-1003',
      'name': 'Mark Johnson',
      'email': 'mark.j@example.com',
      'role': 'Security Officer',
      'isActive': false,
    },
    {
      'id': 'U-1004',
      'name': 'Admin User',
      'email': 'admin@safe.gov',
      'role': 'System Admin',
      'isActive': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: Wrap with BlocBuilder when UserManagementBloc is implemented
    final filteredUsers = _dummyUsers.where((user) {
      return (user['name'] as String)
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          (user['email'] as String)
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          (user['role'] as String)
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "User Management",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE8F0FE)),
              ),
              Row(
                children: [
                  const Text("Show Archived",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF7B8DB0))),
                  const SizedBox(width: 8),
                  Switch(
                    value: showArchivedUsers,
                    activeTrackColor: const Color(0xFF0A84FF),
                    activeColor: Colors.white,
                    onChanged: (val) {
                      setState(() {
                        showArchivedUsers = val;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1627),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E2D4A)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    style: const TextStyle(
                        color: Color(0xFFE8F0FE), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Search registered users...",
                      hintStyle: const TextStyle(
                          color: Color(0xFF4A5568), fontSize: 12.5),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF7B8DB0), size: 20),
                      filled: true,
                      fillColor: const Color(0xFF0D1627),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Color(0xFF1E2D4A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Color(0xFF1E2D4A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Color(0xFF0A84FF), width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Custom3dCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 22,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowHeight: 48,
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFF060D1A)),
                  dataRowColor: WidgetStateProperty.resolveWith((states) =>
                      states.contains(WidgetState.hovered)
                          ? const Color(0xFF0D1627).withValues(alpha: 0.8)
                          : Colors.transparent),
                  dividerThickness: 0.5,
                  columns: const [
                    DataColumn(
                        label: Text("ID",
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7B8DB0),
                                fontSize: 12))),
                    DataColumn(
                        label: Text("Name",
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7B8DB0),
                                fontSize: 12))),
                    DataColumn(
                        label: Text("Email",
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7B8DB0),
                                fontSize: 12))),
                    DataColumn(
                        label: Text("Role",
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7B8DB0),
                                fontSize: 12))),
                    DataColumn(
                        label: Text("Status",
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7B8DB0),
                                fontSize: 12))),
                    DataColumn(
                        label: Text("Actions",
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7B8DB0),
                                fontSize: 12))),
                  ],
                  rows: filteredUsers.map((user) {
                    final bool isActive = user['isActive'] as bool;
                    final Color statusColor = isActive
                        ? const Color(0xFF30D158)
                        : const Color(0xFFFF3B30);
                    return DataRow(
                      cells: [
                        DataCell(Text(user['id'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE8F0FE),
                                fontSize: 12))),
                        DataCell(Text(user['name'] as String,
                            style: const TextStyle(
                                color: Color(0xFFE8F0FE), fontSize: 12))),
                        DataCell(Text(user['email'] as String,
                            style: const TextStyle(
                                color: Color(0xFF7B8DB0), fontSize: 12))),
                        DataCell(Text(user['role'] as String,
                            style: const TextStyle(
                                color: Color(0xFFE8F0FE), fontSize: 12))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              isActive ? "Active" : "Disabled",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
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
                                  size: 20,
                                ),
                                onPressed: () {
                                  _showEditUserDialog(context, user);
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  isActive ? Icons.block : Icons.check,
                                  color: isActive
                                      ? Colors.orange
                                      : const Color(0xFF30D158),
                                  size: 20,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Toggled status for ${user['id']} (UI Mock)"),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.archive,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Archived user ${user['id']} (UI Mock)"),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
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
  }

  void _showEditUserDialog(
      BuildContext context, Map<String, dynamic> user) {
    String selectedRole = user['role'] as String;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1627),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF1E2D4A))),
              title: const Text("Edit User Role",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name: ${user['name']}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text("Email: ${user['email']}",
                        style: const TextStyle(color: Color(0xFF7B8DB0))),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      dropdownColor: const Color(0xFF0D1627),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "User Role",
                        labelStyle:
                            const TextStyle(color: Color(0xFF7B8DB0)),
                        filled: true,
                        fillColor: const Color(0xFF060D1A),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      items: [
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
                  child: const Text("Cancel",
                      style: TextStyle(color: Color(0xFF7B8DB0))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("User role updated successfully (UI Mock)"),
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
